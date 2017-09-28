#!/usr/bin/env bash
#
# Generate all the repository Dockerfiles from templates
#

set -euo pipefail

declare -A modClusterVersions=(
	['1.3']='1.3.7.Final'
)

declare -A modClusterMd5sums=(
	['1.3']='36d9053fcfdcf561479e229bac759eef'
)

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

versions=( "$@" )
if [ ${#versions[@]} -eq 0 ]; then
	versions=( */ )
fi
versions=( "${versions[@]%/}" )

for version in "${versions[@]}"; do
	modClusterVersion="${modClusterVersions[$version]}"
	modClusterMd5sum="${modClusterMd5sums[$version]}"

	for variant in "$version"/*/; do
		variant="$(basename "$variant")" # "2.4" or "2.4-alpine"
		httpdVariant="${variant%-*}" # "2.4"
		shopt -s extglob
		subVariant="${variant##${httpdVariant}?(-)}" # "" or "alpine"
		shopt -u extglob

		case "$subVariant" in
			centos)
				# no "centos" variant in official httpd repo
				baseImage='antoineco\/httpd'
				;;
			*)
				baseImage='httpd'
				;;
		esac

		case "$variant" in
			2.*)
				baseImage+=":${httpdVariant}${subVariant:+-$subVariant}" # ":2.4" or ":2.4-alpine"
				;;
			*)
				echo >&2 "not sure what to do with $version/$variant re: baseImage; skipping"
				continue
				;;
		esac

		cp -v "Dockerfile${subVariant:+-$subVariant}.template" "$version/$variant/Dockerfile"
		cp -v proxy-cluster.conf "$version/$variant/"

		sed -ri -e \
			" \
				s/__BASEIMAGE__/$baseImage/; \
				s/__MODCLUSTERVERSION__/$modClusterVersion/; \
				s/__MODCLUSTERMD5SUM__/$modClusterMd5sum/ \
			" \
			"$version/$variant/Dockerfile"

	done
done

