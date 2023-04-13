// Entry point for the build script in your package.json
//import "@hotwired/turbo-rails"
import "./controllers"

// happening because of item 100 within Chapter 7
// The two following lines disable Turbo on the whole application
import { Turbo } from "@hotwired/turbo-rails"
Turbo.session.drive = false
