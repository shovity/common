const { exec } = require('node:child_process')
const { create, Router, config } = require('eroc')

const manager = {
  log: async ({ home, service }) => {
    return await execute(`
      cd ${home}/${service}-service
      docker compose logs --tail=200
    `)
  },

  release: async ({ home, service }) => {
    return await execute(`
      cd ${home}/${service}-service
      bash bin/release.sh
    `)
  },

  up: async ({ home, service, scale }) => {
    return await execute(`
      cd ${home}/${service}-service
      yarn up prod ${scale}
    `)
  },

  down: async ({ home, service }) => {
    return await execute(`
      cd ${home}/${service}-service
      docker compose down
    `)
  },

  restart: async ({ home, service }) => {
    return await execute(`
      cd ${home}/${service}-service
      docker compose restart
    `)
  },

  git_log_all: async ({ home }) => {
    const raw = await execute(`
      for service in $(ls ${home})
      do
        cd ~/services/$service
        echo "__service===$service "
        git log -5
      done
    `)

    const logs = []

    for (const service of raw.split('__service===')) {
      if (!service) {
        continue
      }

      const name = service.split(' ', 1)[0]

      for (const commit of service.split('\ncommit ')) {
        const shards = commit.split('\n')

        if (shards.length !== 6) {
          continue
        }

        logs.push({
          hash: shards[0],
          service: name.slice(0, -8),
          author: shards[1].slice(8),
          date: shards[2].slice(8),
          message: shards[4].slice(4),
        })
      }
    }

    return logs
  },

  git_show: async ({ home, service, hash }) => {
    return await execute(`
      cd ${home}/${service}-service
      git show ${hash}
    `)
  },

  docker_stats: async () => {
    return await execute(`docker stats --no-stream --format "{{ json . }}"`)
  },
}

const execute = async (command) => {
  return new Promise((resolve, reject) => {
    exec(command, (error, stdout, stderr) => {
      resolve(stdout || stderr)
    })
  })
}

create(async (app) => {
  const router = Router()

  router.post('/', async (req, res, next) => {
    const command = req.gp('command')
    const payload = req.gp('payload', {})
    const key = req.gp('key')
    const home = req.gp('home', config.home)

    const handle = manager[command]
    check(key === config.client, 'Invalid key')
    check(handle, 'Command not found')

    payload.home = home

    return res.success(await handle(payload))
  })

  app.use(router)
})
