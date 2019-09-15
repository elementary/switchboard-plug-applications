/*
* Copyright (c) 2011-2017 elementary LLC. (http://launchpad.net/switchboard-plug-applications)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Akshay Shekher <voldyman666@gmail.com>
*/

namespace Defaults {

    void map_types_to_app (string[] types, GLib.AppInfo app) {
        try {
            for (int i=0; i < types.length; i++) {
                app.set_as_default_for_type (types[i]);
            }
        } catch (GLib.Error e) {
            stdout.printf ("Error: %s\n", e.message);
        }

    }
/*
 * Get the essential types for the apps
 *
 */
    string[] get_types_for_app (string app) {
        switch (app) {
            case "web_browser":
                return { "x-scheme-handler/http",
                        "x-scheme-handler/https",
                        "text/html",
                        "application/x-extension-htm",
                        "application/x-extension-html",
                        "application/x-extension-shtml",
                        "application/xhtml+xml",
                        "application/x-extension-xht"
                };

            case "email_client":
                return { "x-scheme-handler/mailto"
                };

            case "calendar":
                return { "text/calendar"
                };

            case "video_player":
                return { "application/x-quicktimeplayer",
                        "application/vnd.rn-realmedia",
                        "application/asx",
                        "application/x-mplayer2",
                        "application/x-ms-wmv",
                        "video/quicktime",
                        "video/x-quicktime",
                        "video/vnd.rn-realvideo",
                        "video/x-ms-asf-plugin",
                        "video/x-msvideo",
                        "video/msvideo",
                        "video/x-ms-asf",
                        "video/x-ms-wm",
                        "video/x-ms-wmv",
                        "video/x-ms-wmp",
                        "video/x-ms-wvx",
                        "video/mpeg",
                        "video/x-mpeg",
                        "video/x-mpeg2",
                        "video/mp4",
                        "video/3gpp",
                        "video/fli",
                        "video/x-fli",
                        "video/x-flv",
                        "video/vnd.vivo",
                        "video/x-matroska",
                        "video/matroska",
                        "video/x-mng",
                        "video/webm",
                        "video/x-webm",
                        "video/mp2t",
                        "video/vnd.mpegurl",
                        "video/x-ogm+ogg"
                };

            case "music_player":
                return { "audio/ogg",
                        "audio/mpeg",
                        "audio/mp4",
                        "audio/flac",
                        "application/x-musepack",
                        "application/musepack",
                        "application/x-ape",
                        "application/x-id3",
                        "application/ogg",
                        "application/x-ogg",
                        "application/x-vorbis+ogg",
                        "application/x-flac",
                        "application/vnd.rn-realaudio",
                        "application/x-nsv-vp3-mp3",
                        "audio/x-musepack",
                        "audio/musepack",
                        "audio/ape",
                        "audio/x-ape",
                        "audio/x-mp3",
                        "audio/mpeg",
                        "audio/x-mpeg",
                        "audio/x-mpeg-3",
                        "audio/mpeg3",
                        "audio/mp3",
                        "audio/mp4",
                        "audio/x-m4a",
                        "audio/mpc",
                        "audio/x-mpc",
                        "audio/mp",
                        "audio/x-mp",
                        "audio/x-vorbis+ogg",
                        "audio/vorbis",
                        "audio/x-vorbis",
                        "audio/ogg",
                        "audio/x-ogg",
                        "audio/x-flac",
                        "audio/flac",
                        "audio/x-s3m",
                        "audio/x-mod",
                        "audio/x-xm",
                        "audio/x-it",
                        "audio/x-pn-realaudio",
                        "audio/x-realaudio",
                        "audio/x-pn-realaudio-plugin",
                        "audio/x-ms-wmv",
                        "audio/x-ms-wax",
                        "audio/x-ms-wma",
                        "audio/wav",
                        "audio/x-wav",
                        "audio/mpeg2",
                        "audio/x-mpeg2",
                        "audio/x-mpeg3",
                        "audio/x-mpegurl",
                        "audio/basic",
                        "audio/x-basic",
                        "audio/midi",
                        "audio/x-scpls",
                        "audio/webm",
                        "audio/x-webm"
                };

            case "image_viewer":
                return { "image/jpeg",
                        "image/jpg",
                        "image/pjpeg",
                        "image/png",
                        "image/tiff",
                        "image/x-3fr",
                        "image/x-adobe-dng",
                        "image/x-arw",
                        "image/x-bay",
                        "image/x-bmp",
                        "image/x-canon-cr2",
                        "image/x-canon-crw",
                        "image/x-cap",
                        "image/x-cr2",
                        "image/x-crw",
                        "image/x-dcr",
                        "image/x-dcraw",
                        "image/x-dcs",
                        "image/x-dng",
                        "image/x-drf",
                        "image/x-eip",
                        "image/x-erf",
                        "image/x-fff",
                        "image/x-fuji-raf",
                        "image/x-iiq",
                        "image/x-k25",
                        "image/x-kdc",
                        "image/x-mef",
                        "image/x-minolta-mrw",
                        "image/x-mos",
                        "image/x-mrw",
                        "image/x-nef",
                        "image/x-nikon-nef",
                        "image/x-nrw",
                        "image/x-olympus-orf",
                        "image/x-orf",
                        "image/x-panasonic-raw",
                        "image/x-pef",
                        "image/x-pentax-pef",
                        "image/x-png",
                        "image/x-ptx",
                        "image/x-pxn",
                        "image/x-r3d",
                        "image/x-raf",
                        "image/x-raw",
                        "image/x-raw",
                        "image/x-rw2",
                        "image/x-rwl",
                        "image/x-rwz",
                        "image/x-sigma-x3f",
                        "image/x-sony-arw",
                        "image/x-sony-sr2",
                        "image/x-sony-srf",
                        "image/x-sr2",
                        "image/x-srf",
                        "image/x-x3f"
                };

            case "text_editor":
                return { "application/xml",
                        "application/x-perl",
                        "text/mathml",
                        "text/plain",
                        "text/xml",
                        "text/x-c++hdr",
                        "text/x-c++src",
                        "text/x-xsrc",
                        "text/x-chdr",
                        "text/x-csrc",
                        "text/x-dtd",
                        "text/x-java",
                        "text/x-python",
                        "text/x-sql"
                };

            case "file_browser":
                return { "inode/directory",
                        "x-directory/normal",
                        "x-directory/gnome-default-handler"
                };

            default:
                return {};
        }
    }
}
