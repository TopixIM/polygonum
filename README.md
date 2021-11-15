
Polygonum
------

> A chat app.

### Usages

Install Node.js, Yarn, [Calcit](https://github.com/calcit-lang/calcit_runner.rs) to start.

Notice that you need to clone dependencies into `.config/calcit/modules/` manually.

```bash
yarn
yarn watch-page # watch compile page code

yarn vite # for browser app

mode=dev cr --entry server # for starting server
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

Add topic reply:

```cirru
d! :topic/reply $ {}
  :topic-id |demo-id
  :text |demo
```

Remove topic reply:

```cirru
d! :topic/remove-reply $ {}
  :topic-id |demo-id
  :id |demo-id
```

### Workflow

https://github.com/Cumulo/calcium-workflow.calcit

### License

MIT
