use bevy::{
    audio::AudioPlugin,
    prelude::*,
};
// use bevy_old_tv_shader::prelude::*;

use nano9::prelude::*;
use std::io;
// mod covers;

fn main() -> io::Result<()> {
    let content = include_str!("../assets/Nano9.toml");
    let mut config: Config = toml::from_str::<Config>(content)
        .map_err(|e| io::Error::new(io::ErrorKind::Other, format!("{e}")))?;
    config
        .inject_template(None)
        .map_err(|e| io::Error::new(io::ErrorKind::Other, format!("{e}")))?;

    let mut app = App::new();
    app
        .add_systems(PreUpdate, run_pico8_when_loaded)
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

    app.add_plugins(Nano9Plugins { config })
       .add_plugins(bevy_framepace::FramepacePlugin)
       .insert_resource(bevy_framepace::FramepaceSettings::default().with_limiter(bevy_framepace::Limiter::from_framerate(60.0)))
    // .add_plugins(nano9::raycast::RaycastPlugin)
    // .add_plugins(OldTvPlugin)
    ;

    app.run();
    Ok(())
}

