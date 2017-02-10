#!/usr/bin/env bash
#
# Generate all the repository Dockerfiles from templates
#

set -euo pipefail

declare -A modClusterVersions=(
	['1.3']='1.3.5.Final'
	['1.3cr']='1.3.6.CR1'
)

declare -A modClusterMd5sums=(
	['1.3']='91c54d6e87141acbbf854c39a48872c9'
	['1.3cr']='5925f7c1d33f998f1c5e33ff8820ba32'
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

		baseImage='httpd'
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

