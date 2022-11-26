//! main.rs

use std::net::TcpListener;

use zero2prod::startup::run;

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let config = zero2prod::settings::get_configuration().expect("Failed to read configuration.");

    let address = format!(
        "127.0.0.1:{}",
        config.get::<String>("application_port").unwrap()
    );
    let listener = TcpListener::bind(address)?;
    run(listener)?.await
}
