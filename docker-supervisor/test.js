const { exec } = require('node:child_process')

const execute = async (command) => {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      resolve(stdout || stderr)
    })
  })
}

execute(`
cd ~/services/doctor-service
git show 50678d108116548b58b047a6c7cf2dbb2ee7f94d                                  
`).then(console.log)
