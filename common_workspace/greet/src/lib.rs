

pub fn hello(name: &str) -> String {
    let now = time::OffsetDateTime::now_utc();
    format!("Hello {name} at {now}")
}