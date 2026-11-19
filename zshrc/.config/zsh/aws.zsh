# AWS helpers, loaded by ~/.zshrc. This repo is public, so anything
# account-specific lives in ~/.zshrc.local instead:
#   export ECR_REGISTRY=<account-id>.dkr.ecr.<region>.amazonaws.com   # awslogin, updateAppsmithVersion
#   export RDS_DB_USER=<iam-db-user>                                   # dbAuth (defaults to $USER)
#
#   awslogin [profile]             SSO login (skipped if still valid), sets AWS_PROFILE, logs Docker in to ECR
#   rds [profile]                  pick an RDS instance or cluster endpoint; prints "<profile> <endpoint>"
#   dbAuth <mysql|postgres> [profile]   IAM auth token for that endpoint, copied to the clipboard
#   updateAppsmithVersion [version]     build, tag and push the Appsmith image to ECR (run in its repo)

export AWS_REGION=${AWS_REGION:-us-east-1}

_aws_need() {
  local c
  for c in "$@"; do
    command -v "$c" >/dev/null || { echo "$c is not installed (see ~/repos/dotfiles/Brewfile)" >&2; return 1; }
  done
}

# Pick a profile from ~/.aws/config and ~/.aws/credentials. Messages go to
# stderr so callers using $(...) only capture the profile name.
select_aws_profile() {
  _aws_need aws fzf || return 1
  local profiles profile
  profiles=$(aws configure list-profiles 2>/dev/null)
  if [[ -z $profiles ]]; then
    echo "No AWS profiles found. Copy ~/.aws/config over or run: aws configure sso" >&2
    return 1
  fi
  profile=$(fzf --header "Select your AWS profile" <<< "$profiles")
  [[ -z $profile ]] && { echo "No profile selected." >&2; return 1; }
  print -r -- "$profile"
}

awslogin() {
  _aws_need aws || return 1
  local profile=$1
  if [[ -z $profile ]]; then
    profile=$(select_aws_profile) || return 1
  fi

  if aws sts get-caller-identity --profile "$profile" >/dev/null 2>&1; then
    echo "Already logged in as $profile"
  else
    aws sso login --profile "$profile" || return 1
  fi
  export AWS_PROFILE=$profile   # later aws commands in this shell use it

  [[ -z $ECR_REGISTRY ]] && return 0
  _aws_need docker || return 1
  if aws ecr get-login-password --region "$AWS_REGION" --profile "$profile" \
      | docker login --username AWS --password-stdin "$ECR_REGISTRY" >/dev/null; then
    echo "Docker logged in to ECR"
  else
    echo "Docker login to ECR failed. Is Rancher Desktop running?" >&2
    return 1
  fi
}

rds() {
  _aws_need aws fzf || return 1
  local profile=$1 instances clusters endpoint
  if [[ -z $profile ]]; then
    profile=$(select_aws_profile) || return 1
  fi

  instances=$(aws rds describe-db-instances --profile "$profile" \
    --query 'DBInstances[].Endpoint.Address' --output text) \
    || { echo "Could not list RDS instances. Try: awslogin $profile" >&2; return 1; }
  clusters=$(aws rds describe-db-clusters --profile "$profile" \
    --query 'DBClusters[].[Endpoint,ReaderEndpoint]' --output text) || return 1

  endpoint=$(print -r -- "$instances"$'\t'"$clusters" | tr '\t ' '\n\n' \
    | grep -v -e '^$' -e '^None$' | sort -u \
    | fzf --header "Select an RDS endpoint")
  [[ -z $endpoint ]] && { echo "No RDS endpoint selected." >&2; return 1; }
  print -r -- "$profile $endpoint"
}

dbAuth() {
  local port
  case $1 in
    mysql)    port=3306 ;;
    postgres) port=5432 ;;
    *) echo "Usage: dbAuth <mysql|postgres> [profile]" >&2; return 1 ;;
  esac

  local result profile host token user=${RDS_DB_USER:-$USER}
  result=$(rds "$2") || return 1
  profile=${result%% *}
  host=${result#* }

  token=$(aws rds generate-db-auth-token --hostname "$host" --port "$port" \
    --region "$AWS_REGION" --username "$user" --profile "$profile") || return 1
  print -rn -- "${token//[[:space:]]/}" | pbcopy
  echo "Token for $user@$host:$port ($profile) copied to the clipboard. It expires in 15 minutes."
}

updateAppsmithVersion() {
  [[ -z $ECR_REGISTRY ]] && { echo "Set ECR_REGISTRY in ~/.zshrc.local first." >&2; return 1; }
  _aws_need docker || return 1
  local version=$1 image
  [[ -z $version ]] && read "version?Appsmith version to deploy: "
  [[ -z $version ]] && { echo "Version cannot be empty." >&2; return 1; }

  image="$ECR_REGISTRY/hc/appsmith:$version"
  if docker build -t "hc/appsmith:$version" . \
      && docker tag "hc/appsmith:$version" "$image" \
      && docker push "$image"; then
    echo "Pushed $image"
  else
    echo "Build or push failed. If the push was denied, run awslogin first." >&2
    return 1
  fi
}
