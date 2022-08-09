import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ggi_chat/src/widgets/chat.dart';
import 'package:ggi_chat/src/widgets/sticker.dart';

import '../models/input_clear_mode.dart';
import '../models/send_button_visibility_mode.dart';
import 'attachment_button.dart';
import 'inherited_chat_theme.dart';
import 'inherited_l10n.dart';
import 'input_text_field_controller.dart';
import 'send_button.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

/// A class that represents bottom bar widget with a text field, attachment and
/// send buttons inside. By default hides send button when text field is empty.
class Input extends StatefulWidget {
  /// Creates [Input] widget.
  const Input({
    super.key,
    this.isAttachmentUploading,
    this.onAttachmentPressed,
    required this.onSendPressed,
    required this.builder,
    required this.onStickerPressed,
    this.options = const InputOptions(),
  });

  /// Whether attachment is uploading. Will replace attachment button with a
  /// [CircularProgressIndicator]. Since we don't have libraries for
  /// managing media in dependencies we have no way of knowing if
  /// something is uploading so you need to set this manually.
  final bool? isAttachmentUploading;

  /// See [AttachmentButton.onPressed].
  final VoidCallback? onAttachmentPressed;

  final ChatEmojiBuilder builder;

  final void Function(File sticker)
  onStickerPressed;

  /// Will be called on [SendButton] tap. Has [types.PartialText] which can
  /// be transformed to [types.TextMessage] and added to the messages list.
  final void Function(types.PartialText) onSendPressed;

  /// Customisation options for the [Input].
  final InputOptions options;

  @override
  State<Input> createState() => _InputState();
}

/// [Input] widget state.
class _InputState extends State<Input> {
  late final _inputFocusNode = FocusNode(
    onKeyEvent: (node, event) {
      if (event.physicalKey == PhysicalKeyboardKey.enter &&
          !HardwareKeyboard.instance.physicalKeysPressed.any(
            (el) => <PhysicalKeyboardKey>{
              PhysicalKeyboardKey.shiftLeft,
              PhysicalKeyboardKey.shiftRight,
            }.contains(el),
          )) {
        if (event is KeyDownEvent) {
          _handleSendPressed();
        }
        return KeyEventResult.handled;
      } else {
        return KeyEventResult.ignored;
      }
    },
  );

  bool _sendButtonVisible = false;
  late TextEditingController _textController;
  bool _emojiShowing = false;

  @override
  void initState() {
    super.initState();

    _textController =
        widget.options.textEditingController ?? InputTextFieldController();
    _handleSendButtonVisibilityModeChange();
  }

  @override
  void didUpdateWidget(covariant Input oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options.sendButtonVisibilityMode !=
        oldWidget.options.sendButtonVisibilityMode) {
      _handleSendButtonVisibilityModeChange();
    }
  }

  @override
  void dispose() {
    _inputFocusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    widget.builder.call(hideEmoji);
    return GestureDetector(
      onTap: () => _inputFocusNode.requestFocus(),
      child: _inputBuilder(),
    );
  }

  void hideEmoji() {
    if(mounted) {
      setState(() {
        _emojiShowing = false;
      });
    }
  }

  void _handleSendButtonVisibilityModeChange() {
    _textController.removeListener(_handleTextControllerChange);
    if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.hidden) {
      _sendButtonVisible = false;
    } else if (widget.options.sendButtonVisibilityMode ==
        SendButtonVisibilityMode.editing) {
      _sendButtonVisible = _textController.text.trim() != '';
      _textController.addListener(_handleTextControllerChange);
    } else {
      _sendButtonVisible = true;
    }
  }

  void _handleSendPressed() {
    final trimmedText = _textController.text.trim();
    if (trimmedText != '') {
      final partialText = types.PartialText(text: trimmedText);
      widget.onSendPressed(partialText);

      if (widget.options.inputClearMode == InputClearMode.always) {
        _textController.clear();
      }
    }
  }

  void _handleTextControllerChange() {
    setState(() {
      _sendButtonVisible = _textController.text.trim() != '';
    });
  }

  int emojiIndex = 0;
  Widget _inputBuilder() {
    final query = MediaQuery.of(context);
    final buttonPadding = InheritedChatTheme.of(context)
        .theme
        .inputPadding
        .copyWith(left: 3, right: 16);
    final safeAreaInsets = kIsWeb
        ? EdgeInsets.zero
        : EdgeInsets.fromLTRB(
            query.padding.left,
            0,
            query.padding.right,
            query.viewInsets.bottom + query.padding.bottom,
          );
    final textPadding = InheritedChatTheme.of(context)
        .theme
        .inputPadding
        .copyWith(left: 0, right: 0)
        .add(
          EdgeInsets.fromLTRB(
            widget.onAttachmentPressed != null ? 0 : 24,
            0,
            _sendButtonVisible ? 0 : 24,
            0,
          ),
        );

    return Focus(
      autofocus: true,
      child: Padding(
        padding: InheritedChatTheme.of(context).theme.inputMargin,
        child: Material(
          borderRadius: InheritedChatTheme.of(context).theme.inputBorderRadius,
          color: InheritedChatTheme.of(context).theme.inputBackgroundColor,
          child: Container(
            decoration:
                InheritedChatTheme.of(context).theme.inputContainerDecoration,
            padding: safeAreaInsets,
            child: Column(
              children: [
                Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left:5.0,right: 3.0),
                      child: SizedBox(
                        height: 35.0,
                        width: 35.0,
                        child: InkWell(
                            onTap: () {
                              setState(() {
                                _emojiShowing = !_emojiShowing;
                                emojiIndex = 0;
                                // if(_emojiShowing) {
                                //   _inputFocusNode.requestFocus();
                                // }
                              });
                            },
                            child: Image.asset(
                              'assets/icon-emoji.png',
                              package: 'ggi_chat',
                            )),
                      ),
                    ),
                    if (widget.onAttachmentPressed != null)
                      AttachmentButton(
                        isLoading: widget.isAttachmentUploading ?? false,
                        onPressed: widget.onAttachmentPressed,
                        padding: buttonPadding,
                      ),
                    Expanded(
                      child: Padding(
                        padding: textPadding,
                        child: TextField(
                          controller: _textController,
                          cursorColor: InheritedChatTheme.of(context)
                              .theme
                              .inputTextCursorColor,
                          decoration: InheritedChatTheme.of(context)
                              .theme
                              .inputTextDecoration
                              .copyWith(
                            hintStyle: InheritedChatTheme.of(context)
                                .theme
                                .inputTextStyle
                                .copyWith(
                              color: InheritedChatTheme.of(context)
                                  .theme
                                  .inputTextColor
                                  .withOpacity(0.5),
                            ),
                            hintText:
                            InheritedL10n.of(context).l10n.inputPlaceholder,
                          ),
                          focusNode: _inputFocusNode,
                          keyboardType: TextInputType.multiline,
                          maxLines: 5,
                          minLines: 1,
                          onChanged: widget.options.onTextChanged,
                          onTap: widget.options.onTextFieldTap,
                          style: InheritedChatTheme.of(context)
                              .theme
                              .inputTextStyle
                              .copyWith(
                            color: InheritedChatTheme.of(context)
                                .theme
                                .inputTextColor,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: buttonPadding.bottom + buttonPadding.top + 24,
                      ),
                      child: Visibility(
                        visible: _sendButtonVisible,
                        child: SendButton(
                          onPressed: _handleSendPressed,
                          padding: buttonPadding,
                        ),
                      ),
                    ),
                  ],
                ),
                Visibility(
                    visible: _emojiShowing,
                    child: SizedBox(
                      height: 250,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 50.0,
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(right: 10.0),
                                  child: InkWell(
                                      child: Chip(
                                        labelPadding: const EdgeInsets.all(2.0),
                                        label: AutoSizeText(
                                          'Emotion Icon',
                                          style: TextStyle(
                                            color:  emojiIndex == 0 ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        backgroundColor: emojiIndex == 0 ? Colors.blue : const Color(0xFFE5E5E5),
                                        elevation: 6.0,
                                        shadowColor: Colors.grey[60],
                                        padding: const EdgeInsets.all(8.0),
                                      ),
                                      onTap: () {
                                        setState(() {
                                          emojiIndex = 0;
                                        });
                                      }
                                  ),
                                ),
                                InkWell(
                                    child: Chip(
                                      labelPadding: const EdgeInsets.all(2.0),
                                      label: AutoSizeText(
                                        'Sticker',
                                        style: TextStyle(
                                          color:  emojiIndex == 1 ? Colors.white : Colors.black,
                                        ),
                                      ),
                                      backgroundColor: emojiIndex == 1 ? Colors.blue : const Color(0xFFE5E5E5),
                                      elevation: 6.0,
                                      shadowColor: Colors.grey[60],
                                      padding: const EdgeInsets.all(8.0),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        emojiIndex = 1;
                                      });
                                    }
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child:
                            emojiIndex == 0 ?
                            EmojiPicker(
                                onEmojiSelected: (Category category, Emoji emoji) {
                                  _onEmojiSelected(emoji);
                                },
                                onBackspacePressed: _onBackspacePressed,
                                config: Config(
                                    columns: 7,
                                    emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                                    verticalSpacing: 0,
                                    horizontalSpacing: 0,
                                    initCategory: Category.RECENT,
                                    bgColor: Colors.black,
                                    indicatorColor: Colors.blue,
                                    iconColor: Colors.grey,
                                    iconColorSelected: Colors.blue,
                                    progressIndicatorColor: Colors.blue,
                                    backspaceColor: Colors.blue,
                                    skinToneDialogBgColor: Colors.white,
                                    skinToneIndicatorColor: Colors.grey,
                                    enableSkinTones: true,
                                    showRecentsTab: true,
                                    recentsLimit: 28,
                                    noRecents: const Text(
                                      'No Recents',
                                      style: TextStyle(fontSize: 20, color: Colors.black26),
                                      textAlign: TextAlign.center,
                                    ),
                                    tabIndicatorAnimDuration: kTabScrollDuration,
                                    categoryIcons: const CategoryIcons(),
                                    buttonMode: ButtonMode.MATERIAL))
                                :
                            Column(
                              children: [
                                Expanded(child: GridView(
                                  scrollDirection: Axis.horizontal,
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 160,
                                      childAspectRatio: 2.25 / 2,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5
                                  ),
                                  children: stickers() ,
                                )),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: SizedBox(height: 20.0,child: Row(
                                    children: [
                                      stickerSelection("assets/icon-cat.png",1),
                                      stickerSelection("assets/icon-rabbit.png",2),
                                      stickerSelection("assets/icon-panda.png",3),
                                    ],
                                  ),),
                                )
                              ],
                            ),
                          ),
                          Container(height: 5.0,)
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget stickerSelection(String icon, int index) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        child:
        ImageIcon(AssetImage(icon,package: 'ggi_chat'),
          color: emojiIndex == index ? Colors.blue : Colors.grey.shade400,),
        onTap: () {
          setState(() {
            emojiIndex = index;
          });},
      ),
    );
  }
  List<Widget> stickers() {
    if(emojiIndex == 1) {
      return Stickers.mimiCatStickers(widget.onStickerPressed);
    }
    else if(emojiIndex == 2) {
      return Stickers.usagyuunStickers(widget.onStickerPressed);
    }
    else if(emojiIndex == 3) {
      return Stickers.pandaStickers(widget.onStickerPressed);
    }
    else {
      return [Container()];
    }
  }

  _onEmojiSelected(Emoji emoji) {
    _textController
      ..text += emoji.emoji
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
  }

  _onBackspacePressed() {
    _textController
      ..text = _textController.text.characters.skipLast(1).toString()
      ..selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length));
  }
}

@immutable
class InputOptions {
  const InputOptions({
    this.inputClearMode = InputClearMode.always,
    this.onTextChanged,
    this.onTextFieldTap,
    this.sendButtonVisibilityMode = SendButtonVisibilityMode.editing,
    this.textEditingController,
  });

  /// Controls the [Input] clear behavior. Defaults to [InputClearMode.always].
  final InputClearMode inputClearMode;

  /// Will be called whenever the text inside [TextField] changes.
  final void Function(String)? onTextChanged;

  /// Will be called on [TextField] tap.
  final VoidCallback? onTextFieldTap;

  /// Controls the visibility behavior of the [SendButton] based on the
  /// [TextField] state inside the [Input] widget.
  /// Defaults to [SendButtonVisibilityMode.editing].
  final SendButtonVisibilityMode sendButtonVisibilityMode;

  /// Custom [TextEditingController]. If not provided, defaults to the
  /// [InputTextFieldController], which extends [TextEditingController] and has
  /// additional fatures like markdown support. If you want to keep additional
  /// features but still need some methods from the default [TextEditingController],
  /// you can create your own [InputTextFieldController] (imported from this lib)
  /// and pass it here.
  final TextEditingController? textEditingController;
}
