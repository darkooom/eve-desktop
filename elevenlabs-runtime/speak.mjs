import { ElevenLabsClient } from "@elevenlabs/elevenlabs-js";
import dotenv from "dotenv";
import { createWriteStream, unlinkSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { randomUUID } from "node:crypto";
import { Readable } from "node:stream";
import { pipeline } from "node:stream/promises";
import { once } from "node:events";
import { spawn } from "node:child_process";

const environmentFile = process.env.ELEVENLABS_ENV_FILE;
if (environmentFile) dotenv.config({ path: environmentFile, quiet: true });

if (process.argv[2] === "--list") {
  const client = new ElevenLabsClient();
  const result = await client.voices.search({ pageSize: 100 });
  const voices = result.voices.map(voice => ({
    id: voice.voiceId,
    name: voice.name,
    language: voice.labels?.language ?? "",
    category: voice.category ?? "",
  }));
  process.stdout.write(JSON.stringify(voices));
  process.exit(0);
}

const [voiceId, modelId = "eleven_flash_v2_5", languageCode = "de"] = process.argv.slice(2);
const chunks = [];
for await (const chunk of process.stdin) chunks.push(chunk);
const text = Buffer.concat(chunks).toString("utf8").trim();

if (!voiceId || !text) process.exit(0);

const output = join(tmpdir(), `eve-desktop-elevenlabs-${process.pid}-${randomUUID()}.mp3`);
let player;

function cleanup() {
  try { unlinkSync(output); } catch {}
}

function stop() {
  if (player && !player.killed) player.kill("SIGTERM");
  cleanup();
  process.exit(0);
}

process.on("SIGINT", stop);
process.on("SIGTERM", stop);

try {
  const client = new ElevenLabsClient();
  const audio = await client.textToSpeech.convert(voiceId, {
    text,
    modelId,
    languageCode,
    outputFormat: "mp3_44100_128",
    applyTextNormalization: "auto",
    voiceSettings: {
      stability: 0.4,
      similarityBoost: 0.75,
    },
  });
  await pipeline(Readable.fromWeb(audio), createWriteStream(output, { mode: 0o600 }));
  player = spawn("/usr/bin/afplay", [output], { stdio: "ignore" });
  const [code] = await once(player, "exit");
  if (code && code !== 143) process.exitCode = code;
} finally {
  cleanup();
}
