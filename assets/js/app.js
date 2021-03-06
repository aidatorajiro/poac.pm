// We need to import the CSS/SCSS so that webpack will load it.
// The ExtractTextPlugin is used to separate it out into
// its own CSS/SCSS file.
import css from "../css/app.css";
import scss from "../scss/app.scss";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative
// paths "./socket" or full ones "web/static/js/socket".

// import socket from "./socket"

import Elm from "../elm/Main.elm"


const app = Elm.Main.embed(
    document.getElementById("elm"),
    Math.floor(Math.random()*0x0FFFFFFF)
);
app.ports.selectMeta.send(document.querySelector("meta[name=csrf]").content);
