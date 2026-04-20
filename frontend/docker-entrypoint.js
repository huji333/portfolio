#!/usr/bin/env node

const { spawn } = require('node:child_process')

const env = { ...process.env }

;(async() => {
  // launch application
  const args = process.argv.slice(2)
  await exec(args)
})()

function exec(args) {
  const [cmd, ...rest] = args
  const child = spawn(cmd, rest, { stdio: 'inherit', env })
  return new Promise((resolve, reject) => {
    child.on('exit', code => {
      if (code === 0) {
        resolve()
      } else {
        reject(new Error(`${args.join(' ')} failed rc=${code}`))
      }
    })
  })
}
