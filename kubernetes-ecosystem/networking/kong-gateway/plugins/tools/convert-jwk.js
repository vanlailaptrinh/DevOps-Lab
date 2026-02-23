// Usage:
// 1. Save the JWK to a file named jwk.json
// 2. Run this script: node convert-jwk.js
// 3. The PEM will be saved to public.pem


const fs = require("fs");
const jwkToPem = require("jwk-to-pem");

const jwk = JSON.parse(fs.readFileSync("jwk.json"));
const pem = jwkToPem(jwk);

fs.writeFileSync("public.pem", pem);
console.log("Done. PEM saved to public.pem");




