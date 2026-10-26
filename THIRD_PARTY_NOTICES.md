# Third-party notices

EVE Desktop preserves the upstream notices in `LICENSE` and `LICENSE-Plip`. The optional ElevenLabs runtime is installed from the exact versions in `elevenlabs-runtime/package-lock.json` and includes these packages:

| Package | Version | License |
|---|---:|---|
| `@elevenlabs/elevenlabs-js` | 2.74.0 | MIT |
| `command-exists` | 1.2.9 | MIT |
| `dotenv` | 18.0.9 | BSD-2-Clause |
| `node-fetch` | 2.7.0 | MIT |
| `tr46` | 0.0.3 | MIT |
| `webidl-conversions` | 3.0.1 | BSD-2-Clause |
| `whatwg-url` | 5.0.0 | MIT |
| `ws` | 8.22.0 | MIT |

`npm ci` retains each dependency's packaged license file inside `EVE Desktop.app/Contents/Resources/elevenlabs-runtime/node_modules`. The published `tr46` 0.0.3 package declares MIT in its package metadata but omits a license file; its MIT grant is reproduced below with its package author identified from that metadata.

## tr46 0.0.3 — MIT

Copyright (c) Sebastian Mayr

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
