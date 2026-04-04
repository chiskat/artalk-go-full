ARTALK_VERSION_PREFIX="$(curl -fsSL https://api.github.com/repos/ArtalkJS/Artalk/releases/latest \
  | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n 1)"

ARTALK_VERSION="${ARTALK_VERSION_PREFIX#v}"

UPGIT_VERSION_PREFIX="$(curl -fsSL https://api.github.com/repos/pluveto/upgit/releases/latest \
  | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p' \
  | head -n 1)"

UPGIT_VERSION="${UPGIT_VERSION_PREFIX#v}"

IPREGION_REF="$(curl -fsSL "https://api.github.com/repos/lionsoul2014/ip2region/commits?path=data/ip2region_v4.xdb&per_page=1" \
  | sed -n 's/.*"sha":[[:space:]]*"\([0-9a-f]\{40\}\)".*/\1/p' \
  | head -n 1)"

IPREGION_REF_SHORT="$(printf '%s' "$IPREGION_REF" | cut -c1-7)"

CALVER=$(date -d "@$(($(date +%s) + 8 * 3600))" "+%Y.%-m.%-d")

AIO_VERSION="artalk_$ARTALK_VERSION-upgit_$UPGIT_VERSION-ip2region_$IPREGION_REF_SHORT"

docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg ARTALK_VERSION="$ARTALK_VERSION" \
  --build-arg UPGIT_VERSION="$UPGIT_VERSION_PREFIX" \
  --build-arg IPREGION_REF="$IPREGION_REF" \
  --progress plain \
  --push \
  -t "chiskat/artalk-go-full:$AIO_VERSION" \
  .

docker buildx imagetools create -t "chiskat/artalk-go-full:$CALVER" "chiskat/artalk-go-full:$AIO_VERSION"

docker buildx imagetools create -t "chiskat/artalk-go-full:latest" "chiskat/artalk-go-full:$AIO_VERSION"

docker run --rm \
  -e PUSHRM_TARGET="docker.io/chiskat/artalk-go-full" \
  -e PUSHRM_SHORT="Artalk $ARTALK_VERSION_PREFIX with All-In-One dependencies." \
  -e DOCKER_USER="chiskat" \
  -e DOCKER_PASS="$DOCKER_PASS" \
  -e PUSHRM_FILE="/repo/README.md" \
  -v "./README.md:/repo/README.md" \
  chko/docker-pushrm:1
