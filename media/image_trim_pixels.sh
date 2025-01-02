#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#
#  Author: Hari Sekhon
#  Date: 2025-01-02 08:36:02 +0700 (Thu, 02 Jan 2025)
#
#  https///github.com/HariSekhon/DevOps-Bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help steer this or other code I publish
#
#  https://www.linkedin.com/in/HariSekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck disable=SC1090,SC1091
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Trims N pixels off one of the sides of an image and then automatically opens it to check the result

First arg is the image file to edit

Second arg picks a side - options are one of:

top
bottom
left
right

Third arg is the number of pixels to trim off (default: 1)
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<image> <side> <number_of_pixels>"

help_usage "$@"

min_args 2 "$@"

check_bin magick

image="$1"
side="$2"
pixels="${3:-1}"

# name the new file the same as the old file but with _trimmed suffixed just before the file extension
#
#   eg. my-file.png => my-file_trimmed.png
#
output_image="${image%.*}_trimmed.${image##*.}"

if ! is_int "$pixels"; then
    usage "Pixels must be an integer"
fi

timestamp "Input image: $image"
timestamp "Output image: $output_image"
if [ "$side" = top ]; then
    timestamp "Trimming $pixels pixels off the top"
    magick "$image" -crop +0+"$pixels" +repage "$output_image"
elif [ "$side" = bottom ]; then
    timestamp "Trimming $pixels pixels off the bottom"
    magick "$image" -crop +0+"$pixels" +repage "$output_image"
    magick "$image" -gravity South -chop 0x"$pixels" "$output_image"
elif [ "$side" = right ]; then
    timestamp "Trimming $pixels pixels off the right"
    magick "$image" -gravity East -chop "$pixels"x0 "$output_image"
elif [ "$side" = left ]; then
    timestamp "Trimming $pixels pixels off the left"
    magick "$image" -gravity West -chop "$pixels"x0 "$output_image"
else
    usage "Invalid side selected, must be one of: top, bottom, left, right"
fi

timestamp "Opening image: $output_image"
"$srcdir/imageopen.sh" "$output_image"
