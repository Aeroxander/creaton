#!/usr/bin/env node
const fs = require('fs');
function copyFromDefault(p) {
  if (!fs.existsSync(p)) {
    const defaultFile = `${p}.default`;
    if (fs.existsSync(defaultFile)) {
      fs.copyFileSync(`${p}.default`, p);
    }
  }
}

function writeIfNotExists(p, content) {
  if (!fs.existsSync(p)) {
    fs.writeFileSync(p, content);
  }
}

['creaton.code-workspace', '.env', '.env.production', '.env.staging'].map(
  copyFromDefault
);

switch (process.platform) {
  case 'win32':
    writeIfNotExists(
      '.newsh.json',
      `
{
  "terminalApp": "cmd"
}    
`
    );
    break;
  case 'linux':
    writeIfNotExists(
      '.newsh.json',
      `
  {
    "terminalApp": "xterm"
  }    
  `
      );
    break;
}


const execSync = require('child_process').execSync
function npmInstall (dir) {
  console.log(`INSTALLING ${dir}...`)
  let exitCode = 0;
  try {
    execSync('npm install', { cwd: dir, stdio: 'inherit'})
  } catch (err) {
    exitCode = err.status
  }
  if (exitCode) {
    process.exit(exitCode);
  }
}
npmInstall('common-lib');
npmInstall('contracts');
npmInstall('subgraph');
npmInstall('web');
