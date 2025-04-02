## Welcome To LK Bricks.

Lk Bricks is a home for any lightning kite bricks that developers at Lightning Kite wish to create and use.  What is a brick you may be wondering, they are templates to be used with [mason cli](https://github.com/felangel/mason)

Mason CLI is a templating tool built with Dart, it is however very useful for any text based project.

### Getting Started

First you will need to install dart.  You will find information on how to do so for your given platform [here](https://dart.dev/get-dart).

Install mason cli globally using the command `dart pub global activate mason_cli`.  Create a directory where you wish to add the desired brick, and run the command `mason init`, this will generate a mason.yaml file in the current directory.  to use the lk_kiteui brick you would modifiy the mason.yaml adding the following to the `bricks:` block. 

```
lk_kiteui:
  git:
    url: https://github.com/lightningkite/lk_bricks.git
    path: lk_kiteui
```

Now run `mason get`, followed by `mason make lk_kiteui` it will prompt for some input, and then generate the brick in the current directory.  add the `-o` parameter to the `mason make` command to output your brick to another directory.

### Learn More

To Learn more about mason visit [brickhub docs](https://docs.brickhub.dev/mason-make)