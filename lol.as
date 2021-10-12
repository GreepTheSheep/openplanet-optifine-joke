[Setting name="Enable"]
bool Setting_Enable = true;

[Setting name="Minimum FPS to activate it" min=15 max=240 drag]
int Setting_MinFPS = 22;

bool playedOnce = true;

float fps = 60;

Resources::Font@ font = Resources::GetFont("DroidSans-Bold.ttf", 30);

void RenderMenu() {
  if (UI::MenuItem("Enable Optifine warning", "", Setting_Enable)) {
    Setting_Enable = !Setting_Enable;
  }
}

void Main(){
    while(true){
        yield();
        CHmsViewport@ Viewport = cast<CHmsViewport>(GetApp().Viewport);
        if (Viewport !is null){
            fps = Viewport.AverageFps;
        }
    }
}

void Render(){
    if (Setting_Enable){
        if (fps < Setting_MinFPS){
            nvg::FontSize(28);
            nvg::FontFace(font);
            nvg::TextLetterSpacing(0.3);
            nvg::TextAlign(nvg::Align::Center | nvg::Align::Middle);
            nvg::TextBox(0.4 * Draw::GetWidth() - 100, 0.2 * Draw::GetHeight(), 400, "install optifine for more fps");
            if (!playedOnce) {
                startnew(PlaySoundYield);
                playedOnce = true;
            }
        } else {
            playedOnce = false;
        }
    }
}

void PlaySoundYield(){
    PlaySound();
}

void PlaySound(string FileName = "MatchFound.wav", float Volume = 2, float Pitch = 1.5) {
    auto audioPort = GetApp().AudioPort;
    for (uint i = 0; i < audioPort.Sources.Length; i++) {
        auto source = audioPort.Sources[i];
        auto sound = source.PlugSound;
        if (cast<CSystemFidFile>(GetFidFromNod(sound.PlugFile)).FileName == FileName) {
            source.Stop();
            // Yield twice : Later while loop will be exited by already playing sounds
            // Their coroutines will end and the pitch and volume will be set to the correct values
            yield();yield();
            float PrevPitch = sound.Pitch;
            float PrevSoundVol = sound.VolumedB;
            float PrevSourceVol = source.VolumedB;
            sound.Pitch = Pitch;
            sound.VolumedB = Volume;
            source.VolumedB = Volume;
            source.Play();
            while (source.IsPlaying) {
                yield();
            }
            sound.Pitch = PrevPitch;
            sound.VolumedB = PrevSoundVol;
            source.VolumedB = PrevSourceVol;
            return;
        }
    }
    print("Couldn't find sound to play! Filename: " + FileName);

    // Backup sound: "Race3.wav"
    for (uint i = 0; i < audioPort.Sources.Length; i++) {
        auto source = audioPort.Sources[i];
        auto sound = source.PlugSound;
        if (cast<CSystemFidFile>(GetFidFromNod(sound.PlugFile)).FileName == "aa.wav") {
            source.Stop();
            // Yield twice : Later while loop will be exited by already playing sounds, ending their coroutines
            yield();yield();
            float PrevPitch = sound.Pitch;
            float PrevSoundVol = sound.VolumedB;
            float PrevSourceVol = source.VolumedB;
            sound.Pitch = Pitch;
            source.VolumedB = Volume;
            source.Play();
            while (source.IsPlaying) {
                yield();
            }
            sound.Pitch = PrevPitch;
            sound.VolumedB = PrevSoundVol;
            source.VolumedB = PrevSourceVol;
            return;
        }
    }
    print("Couldn't find backup Race3.wav. Sources:");
    for (uint i = 0; i < audioPort.Sources.Length; i++) {
        auto source = audioPort.Sources[i];
        auto sound = source.PlugSound;
        print("" + cast<CSystemFidFile>(GetFidFromNod(sound.PlugFile)).FileName);
    }
}