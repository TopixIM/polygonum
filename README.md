
Polygonum
------

> A chat app.

### Usages

Install Node.js, Yarn, [Calcit](https://github.com/calcit-lang/calcit_runner.rs) to start.

Notice that you need to clone dependencies into `.config/calcit/modules/` manually.

```bash
yarn

yarn watch-server # watch compile server code

yarn watch-page # watch compile page code

yarn dev-server # watching compiling js code
node js-out/bundle.js

mode=dev node js-out/bundle.js # use mode to control behaviors for development

yarn vite # for browser app
```

code with [calcit-editor](https://github.com/Cirru/calcit-editor).

### Actions

Add card:

```cirru
d! :stack/add $ {} (:name :topics) (:data topic-id)
```

Close card:

```cirru
d! :stack/close idx
```

Add topic:

```cirru
d! :topic/add "|some text"
```

### License

MIT
