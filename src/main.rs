//! main.rs

use std::net::TcpListener;

use sqlx::PgPool;
use zero2prod::{
    settings::DatabaseSettings,
    startup::run,
    telemetry::{get_subscriber, init_subscriber},
};

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let subscriber = get_subscriber("zero2prod".into(), "info".into());
    init_subscriber(subscriber);

    let config = zero2prod::settings::get_configuration().expect("Failed to read configuration.");
    let connection_pool = PgPool::connect(
        &config
            .get::<DatabaseSettings>("database")
            .unwrap()
            .connection_string(),
    )
    .await
    .expect("Failed to connect to Postgres.");

    let address = format!(
        "127.0.0.1:{}",
        config.get::<String>("application_port").unwrap()
    );
    let listener = TcpListener::bind(address)?;
    run(listener, connection_pool)?.await
}
