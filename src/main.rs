use bevy::{
    audio::AudioPlugin,
    prelude::*,
};
// use bevy_minibuffer::prelude::*;
// use bevy_old_tv_shader::prelude::*;

use nano9::{config::Config, pico8::*, error::RunState, *};
use std::io;
// mod covers;

#[allow(dead_code)]
#[derive(Resource)]
struct InitState(Handle<Pico8State>);

fn main() -> io::Result<()> {
    let content = include_str!("../assets/Nano9.toml");
    let config: Config = toml::from_str::<Config>(content)
        .map_err(|e| io::Error::new(io::ErrorKind::Other, format!("{e}")))?
        .inject_template();

    let nano9_plugin = Nano9Plugin { config };
    let mut app = App::new();
        app.add_systems(
            PostStartup,
            move |asset_server: Res<AssetServer>, mut commands: Commands, mut next_state: ResMut<NextState<RunState>>| {
                let pico8state: Handle<Pico8State> = asset_server.load("Nano9.toml");
                commands.insert_resource(InitState(pico8state));
            },
        )
        .add_systems(Update, show_asset_changes::<Image>)
        .add_systems(Update, show_asset_changes::<Gfx>)
        .add_systems(PreUpdate, run_pico8_when_ready)
        // .add_systems(Update, covers::add_covers)
        ;
    // Add the Old TV effect.
    // app.add_systems(
    //     PostStartup,
    //     |cameras: Query<Entity, With<Camera>>, mut commands: Commands| {
    //         for id in &cameras {
    //             commands.entity(id)
    //                     .insert(OldTvSettings {
    //                         screen_shape_factor: 0.0,
    //                         rows: 128.0,
    //                         brightness: 4.0,
    //                         edges_transition_size: 0.025,
    //                         channels_mask_min: 0.1,
    //                     });
    //         }
    //     });

    app.add_plugins(
        DefaultPlugins
            .set(AudioPlugin {
                global_volume: GlobalVolume::new(0.4),
                ..default()
            })
            // .set(ImagePlugin::default_nearest())
            .set(nano9_plugin.window_plugin()),
    )
    .add_plugins(bevy_framepace::FramepacePlugin)
    .insert_resource(bevy_framepace::FramepaceSettings::default().with_limiter(bevy_framepace::Limiter::from_framerate(60.0)))
    .add_plugins(nano9_plugin)
    // .add_plugins(nano9::raycast::RaycastPlugin)
    // .add_plugins(OldTvPlugin)
    ;

    // app
    // .add_plugins(MinibufferPlugins)
    // .add_acts((
    //     BasicActs::default(),
    //     acts::universal::UniversalArgActs::default(),
    //     acts::tape::TapeActs::default(),
    //     nano9::minibuffer::Nano9Acts::default(),
    // ));
    // app.add_acts(bevy_minibuffer_inspector::WorldActs::default());
    app.run();
    Ok(())
}

fn show_asset_changes<T: Asset>(mut reader: EventReader<AssetEvent<T>>) {
    reader
        .read()
        .inspect(|e| info!("asset event {e:?}"));
}
