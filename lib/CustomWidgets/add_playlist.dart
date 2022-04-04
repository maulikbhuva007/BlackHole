import 'package:audio_service/audio_service.dart';
import 'package:blackhole/APIs/api.dart';
import 'package:blackhole/CustomWidgets/collage.dart';
import 'package:blackhole/CustomWidgets/gradient_containers.dart';
import 'package:blackhole/CustomWidgets/snackbar.dart';
import 'package:blackhole/CustomWidgets/textinput_dialog.dart';
import 'package:blackhole/Helpers/audio_query.dart';
import 'package:blackhole/Screens/Common/popup_loader.dart';
import 'package:blackhole/model/custom_playlist_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';
import 'package:on_audio_query/on_audio_query.dart';

class AddToOffPlaylist {
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();

  Future<void> addToOffPlaylist(BuildContext context, int audioId) async {
    List<PlaylistModel> playlistDetails =
        await offlineAudioQuery.getPlaylists();
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return BottomGradientContainer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context)!.createPlaylist),
                  leading: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Icon(
                          Icons.add_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? null
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  onTap: () {
                    // showTextInputDialog(
                    //   context: context,
                    //   keyboardType: TextInputType.text,
                    //   title: AppLocalizations.of(context)!.createNewPlaylist,
                    //   onSubmitted: (String value) async {
                    //     await offlineAudioQuery.createPlaylist(name: value);
                    //     playlistDetails =
                    //         await offlineAudioQuery.getPlaylists();
                    //     Navigator.pop(context);
                    //   },
                    // );
                  },
                ),
                if (playlistDetails.isEmpty)
                  const SizedBox()
                else
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: playlistDetails.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: QueryArtworkWidget(
                            id: playlistDetails[index].id,
                            type: ArtworkType.PLAYLIST,
                            keepOldArtwork: true,
                            artworkBorder: BorderRadius.circular(7.0),
                            nullArtworkWidget: ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: const Image(
                                fit: BoxFit.cover,
                                height: 50.0,
                                width: 50.0,
                                image: AssetImage('assets/cover.jpg'),
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          playlistDetails[index].playlist,
                        ),
                        subtitle: Text(
                          '${playlistDetails[index].numOfSongs} Songs',
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          offlineAudioQuery.addToPlaylist(
                            playlistId: playlistDetails[index].id,
                            audioId: audioId,
                          );
                          ShowSnackBar().showSnackBar(
                            context,
                            '${AppLocalizations.of(context)!.addedTo} ${playlistDetails[index].playlist}',
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AddToPlaylist {
  Box settingsBox = Hive.box('settings');
  List playlistNames = Hive.box('settings')
      .get('playlistNames', defaultValue: ['Favorite Songs']) as List;
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;

  void addToPlaylist(BuildContext context, MediaItem? mediaItem) {
    showModalBottomSheet(
      isDismissible: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        return AddSongToPlayList(
          trackId: mediaItem!.id.toString(),
        );
      },
    );
  }
}

class AddSongToPlayList extends StatefulWidget {
  const AddSongToPlayList({Key? key, this.trackId}) : super(key: key);
  final String? trackId;

  @override
  _AddSongToPlayListState createState() => _AddSongToPlayListState();
}

class _AddSongToPlayListState extends State<AddSongToPlayList> {
  bool loading = false;
  bool dataLoader = false;
  CustomPlaylistResponse? customPlaylistResponse;

  @override
  void initState() {
    // TODO: implement initState
    fetchPlaylistData();
    super.initState();
  }

  Future fetchPlaylistData() async {
    setState(() {
      dataLoader = true;
    });
    customPlaylistResponse = await YogitunesAPI().fetchPlaylistData();
    setState(() {
      dataLoader = false;
    });
  }

  List<String> selectedPlaylist = [];
  OfflineAudioQuery offlineAudioQuery = OfflineAudioQuery();
  @override
  Widget build(BuildContext context) {
    return BottomGradientContainer(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.createPlaylist),
              leading: Card(
                elevation: 0,
                color: Colors.transparent,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: Icon(
                      Icons.add_rounded,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : Colors.grey[700],
                    ),
                  ),
                ),
              ),
              onTap: () {
                print("Hello");
                showTextInputDialog(
                  context: context,
                  keyboardType: TextInputType.text,
                  title: AppLocalizations.of(context)!.createNewPlaylist,
                  onSubmitted: (String value) async {
                    String? playlistId =
                        await YogitunesAPI().createPlaylist(value, context);
                    fetchPlaylistData();
                    Navigator.pop(context);
                  },
                );
              },
            ),
            if (dataLoader)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                reverse: true,
                itemCount: customPlaylistResponse!
                    .data!.length, //playlistNames.length,
                itemBuilder: (context, index) {
                  var playlist = customPlaylistResponse!.data![index].playlist!;
                  var playlistTracks =
                      customPlaylistResponse!.data![index].playlistTracks!;
                  String? imageUrl;
                  PlaylistResponseData itemData =
                      customPlaylistResponse!.data![index];
                  if (itemData.quadImages != null) {
                    if (itemData.quadImages!.isNotEmpty) {
                      if (itemData.quadImages![0] != null) {
                        if (itemData.quadImages![0]!.imageUrl != null) {
                          imageUrl =
                              '${itemData.quadImages![0]!.imageUrl}/${itemData.quadImages![0]!.image}';
                          ;
                        }
                      }
                    }
                  }
                  return ListTile(
                    leading:
                        // playlistDetails[playlistNames[index]] ==
                        //             null ||
                        //         playlistDetails[playlistNames[index]]
                        //                 ['imagesList'] ==
                        //             null
                        //     ?
                        Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        height: 50,
                        width: 50,
                        child: Collage(
                          showGrid: true,
                          imageList: itemData.getQuadImages(),
                          placeholderImage: 'assets/cover.jpg',
                        ),
                        // CachedNetworkImage(
                        //   fit: BoxFit.cover,
                        //   errorWidget: (context, _, __) => const Image(
                        //     fit: BoxFit.cover,
                        //     image: AssetImage(
                        //       'assets/cover.jpg',
                        //     ),
                        //   ),
                        //   imageUrl: '${imageUrl}',
                        //   placeholder: (context, url) => const Image(
                        //     fit: BoxFit.cover,
                        //     image: AssetImage(
                        //       'assets/cover.jpg',
                        //     ),
                        //   ),
                        // ),
                      ),
                      //   )
                      // : Collage(
                      //     imageList: playlistDetails[playlistNames[index]]
                      //         ['imagesList'] as List,
                      //     showGrid: true,
                      //     placeholderImage: 'assets/cover.jpg',
                    ),
                    title: Text(
                      playlist.name.toString(),
                    ),
                    onTap: () async {
                      popupLoader(context, 'Loading');

                      // for (int i = 0; i < playlistTracks.length; i++) {
                      //   selectedPlaylist.insert(
                      //       i, playlistTracks[i].playlistId.toString());
                      //   print(selectedPlaylist);
                      // }

                      if (selectedPlaylist.contains(widget.trackId)) {
                        ShowSnackBar().showSnackBar(
                            context, 'song already exist in playlist');
                        Navigator.pop(context);
                      } else {
                        selectedPlaylist.add(widget.trackId.toString());

                        final res = await YogitunesAPI().editPlaylist(
                          playlist.id!.toString(),
                          playlist.name!,
                          selectedPlaylist,
                          isAdd: true,
                        );

                        if (res['status'] as bool) {
                          ShowSnackBar().showSnackBar(
                              context, 'song successfully added!');
                          Navigator.pop(context);
                          Navigator.pop(context);
                        } else {
                          ShowSnackBar()
                              .showSnackBar(context, res['data'].toString());
                          Navigator.pop(context);
                        }
                      }

                      // Navigator.pop(context);
                      // if (mediaItem != null) {
                      //   addItemToPlaylist(
                      //     playlistNames[index].toString(),
                      //     mediaItem,
                      //   );
                      //   ShowSnackBar().showSnackBar(
                      //     context,
                      //     '${AppLocalizations.of(context)!.addedTo} ${playlistDetails.containsKey(playlistNames[index]) ? playlistDetails[playlistNames[index]]["name"] ?? playlistNames[index] : playlistNames[index]}',
                      //   );
                      // }
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
