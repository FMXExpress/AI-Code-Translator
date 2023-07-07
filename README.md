# AI Code Translator
Translate source code from languages like C++, Python, and C# to Delphi using ChatGPT.

The AI Code Translator Desktop client is a powerful UI for creating translating and converting code between programming languages. Comes with the ability to verify Delphi and C++ code by compiling it and then reporting errors back to ChatGPT.

* Delphi Object Pascal
* C++
* Javascript
* TypeScript
* Python
* Go
* Rust
* C
* C#
* Visual Basic
* Visual Basic .NET
* PHP
* Ruby
* Swift
* Dart
* Kotlin
* R
* Objective-C
* Perl
* Scala
* Haskell
* Lua
* Groovy
* Elixer
* Clojure
* Lisp
* Julia
* Fortran
* COBOL
* Pascal
* Free Pascal

Built with [Delphi](https://www.embarcadero.com/products/delphi/) using the FireMonkey framework this client works on Windows, macOS, and Linux (and maybe Android+iOS) with a single codebase and single UI. At the moment it is specifically set up for Windows.

It features a REST integration with OpenAI.com and ChatGPT for providing source code translation functionality within the client. You need to sign up for an API key to access that functionality. Replicate models can be run in the cloud or locally via docker.

```
docker run -d -p 5000:5000 --gpus=all r8.im/replicate/vicuna-13b@sha256:6282abe6a492de4145d7bb601023762212f9ddbbe78278bd6771c8b3b2f2a13b
curl http://localhost:5000/predictions -X POST -H "Content-Type: application/json" \
  -d '{"input": {
    "prompt": "...",
    "max_length": "...",
    "temperature": "...",
    "top_p": "...",
    "repetition_penalty": "...",
    "seed": "...",
    "debug": "..."
  }}'
```

# AI Code Translator Desktop client Screeshot on Windows
![AI Code Translator Desktop client on Windows](/screenshot.png)

Other Delphi AI clients:

[Stable Diffusion Desktop Client](https://github.com/FMXExpress/Stable-Diffusion-Desktop-Client)

[AI Playground](https://github.com/FMXExpress/AI-Playground-DesktopClient)

[Song Writer AI](https://github.com/FMXExpress/Song-Writer-AI)

[Stable Diffusion Text To Image Prompts](https://github.com/FMXExpress/Stable-Diffusion-Text-To-Image-Prompts)

[Generative AI Prompts](https://github.com/FMXExpress/Generative-AI-Prompts)

[Dreambooth Desktop Client](https://github.com/FMXExpress/DreamBooth-Desktop-Client)

[Text To Vector Desktop Client](https://github.com/FMXExpress/Text-To-Vector-Desktop-Client)
