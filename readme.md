# TrimmerTool
A simplistic clip trimmer designed for automating the annoying task. Better than Pickleknotts' version, guaranteed.

# Notes
This program is WINDOWS ONLY.
This program requires [FFMPEG](https://ffmpeg.org/download.html) to be installed and in the PATH environment.

# Command line
## Usage
`program [input_video] [output_video] [-time=X-Y]`<br>
If no parameters are given, the values will be considered empty.
| Parameter      | Description                                                                                               |
| :---           | :---                                                                                                      |
| `input_video`  | Optional. The video path of the file to clip. If not provided, it will ask.                               |
| `output_video` | Optional. The video path of the file to save to. If not provided, it will ask.                            |
| `-time=X-Y`    | Optional. The time to clip to (X) and from (Y). If Y is not provided, it will assume the end of the clip. |

## Examples
```sh
# Clip the video to the times between 5 and 10. A 5 second clip.
program "C:\My Clips\My Video.mp4" "%dir%\%file_name% - Trimmed.%ext%" -time5-10

# Clip the video only 15 seconds in. Meaning the first 15 seconds of the clip are removed.
program "C:\My Clips\My Video.mp4" "%dir%\%file_name% - Trimmed.%ext%" -time15
```

# Custom Variables
For output file variables:
| Variable      | Replaceable? | Description                                                                                                            | Example Value                         |
| :---          | :---         | :---                                                                                                                   | :---                                  |
| `file_name`   | false        | The name of the file.                                                                                                  | `My Video.mp4`                        |
| `dir`         | false        | The directory of the file.                                                                                             | `C:\My Clips`                         |
| `ext`         | false        | The extension of the file.                                                                                             | `mp4`                                 |
| `name_no_ext` | false        | The name of the file without the extension.                                                                            | `My Video.`                           |
| `drive`       | false        | The drive the file is in.                                                                                              | `C:`                                  |
| `date`        | false        | The current date (yyyy-MM-dd).                                                                                         |                                       |
| `time`        | false        | The current time (HH-mm-ss).                                                                                           |                                       |
| `date_time`   | false        | The current date and time (yyyy-MM-dd HH-mm-ss).                                                                       |                                       |
| `now`         | false        | The current date and time without the fanciness (YYYYMMDDHH24MISS).                                                    |                                       |
| `now_utc`     | false        | The current [Coordinated Universal Time](https://en.wikipedia.org/wiki/Coordinated_Universal_Time) (YYYYMMDDHH24MISS). |                                       |
| `rand`        | false        | A random number between 0 and 100.                                                                                     |                                       |
| `username`    | true         | The username set on this computer.                                                                                     |                                       |
| `documents`   | true         | The current user's documents folder.                                                                                   | `C:\Users\%username%\Documents`       |
| `appdata`     | true         | The current user's appdata folder.                                                                                     | `C:\Users\%username%\Appdata\Roaming` |
| `desktop`     | true         | The current user's desktop folder.                                                                                     | `C:\Users\%username%\Desktop`         |

Custom variables can be put in the [Custom Variables text file.](config/custom_vars.txt)
For example:
```sh
# Steam path.
steam_path = D:\Steam

# Clips folder.
clips = C:\Users\%username%\Videos\Captures

# TF2 and CSGO path.
tf_path = %steam_path%\steamapps\common\Team Fortress 2
csgo_path = %steam_path%\steamapps\common\Counter Strike Global Offensive

# The username I wanna use.
username = JoeSmith
```
