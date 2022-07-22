# Rails + React Todo app

参考： https://zenn.dev/prune/books/0d7d6e3c5f0496
フォルダ back => Rails7
フォルダ front => React18
が入っています

開発時中で起こったことなどを書き記します

### Rails

まず初めに開発効率を上げるためには rails のコマンドを覚えた方がいい

- rails new hoge :: プロジェクト作成
  - いらないファイルは option で選択できる
    - skip-git .gitignore ファイルをスキップする
    - skip-keeps .keep ファイル（バージョン管理用）の生成をスキップする
    - skip-action-mailer Action Mailer のファイルをスキップする
    - skip-action-text Action Text gem をスキップする
    - skip-active-record Active Record のファイルをスキップする
    - skip-active-storage Active Storage のファイルをスキップする
    - skip-action-cable Action Cable のファイルをスキップする
    - skip-sprockets Sprockets のファイルをスキップする
    - skip-javascript JavaScript のファイルをスキップする
    - skip-turbolinks turbolinks gem をスキップする
    - skip-test テストファイルをスキップする
    - skip-system-test システムテストファイルをスキップする
    - skip-bootsnap bootsnap gem をスキップする
    - など
  - 逆も然り option で rails 内に react もインストールできる
    - rails webpacker:install:react
    - など
- rails server :: サーバー起動
  - 今回 react との連携にあたり rails の URL を変更した
  - config/puma.rb の**port ENV.fetch("PORT") { 3000 }**で http://localhost:3000/となるので
  - **port ENV.fetch("PORT") { 3010 }**とし http://localhost:3010/に変更した
- **rails g controller foge**
  - controller 作成
- **rails generate model hoge**
  - model の作成
  - 内容に誤りがなかったら
  - rails db:migrate :: データベース作成
    - rails dbconsole :: 作成した DB の確認

#### 初めての API 作成

おそらく初めて API を作成すると躓くであろう CORS の対策手法
rails 側で行うこと

- Gemfile の gem "rack-cors" を有効化する
- コマンド $ bundle install
- config\initializers\cors.rb ができる

  ```
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # アクセスを許可するオリジン（フロントのアドレス）を指定
    origins "http://localhost:3000", "本番環境でのアドレス"

    resource '*',
      :headers => :any,
      # ユーザー認証関連
      :expose => ['access-token', 'expiry', 'token-type', 'uid', 'client'],

      # リソースに対して許可するHTTPリクエストメソッドを指定
      :methods => [:get, :post, :options, :delete, :put, :head, :patch],

      # Cookieを利用する場合は以下を記述
      :credentials => true
  end
  end
  ```

  を参考に書き換える

[参考](https://qiita.com/tono029/items/f4c98d8eb0d666044f91)

#### Rails 開発中に感じた少しわかり始めてきたこと

views 部分を外部と連携するとき rails 自体の views は全く触らない(API 開発時)
同じく model にも触らない
controllers に処理を書いていく以下今回で書いたもの

```
class TasksController < ApplicationController
  def index
    tasks = Task.all
    render json: tasks
  end

  def create
    # Active Recordの機能であるcreateメソッド
    Task.create(task_params)
    head :created
  end

  def destroy
    task = Task.find(params[:id])
    task.destroy
    head :ok
  end

  def update
    task = Task.find(params[:id])
    task.update(task_params)
    head :ok
  end

  private
  def task_params
    # paramsとはフロントから送られてくるデータ
    # ストロングパラメーターを設定しているparams.permit(:name, :is_done)
    params.require(:task).permit(:name, :is_done)
  end
end

```

---

```
  def index
    tasks = Task.all
    render json: tasks
  end
```

部分では
tasks = Task.all は 任意の変数名= migrate したモデル名.all で
テーブル全部取得

---

```
  private
  def task_params
    params.require(:task).permit(:name, :is_done)
  end
```

部分では
private はいつもどうにクラス内のみアクセス可能にする
params とはフロント(今回は react)から送られてきた値を受け取るためのメソッド
require は変更する model(db)名
permit は受け取るテーブル名に限定に限定する(他のテーブル名は受け付けないイメージ)
ふりがなを振ると
params.require(:task).permit(:name, :is_done) = **taskDB の name&is/dine の情報だけ受け取ります**

---

```
   def create
    Task.create(task_params)
    head :created
  end
```

順番が前後しますが private について先に書くとこれからの関数が読みやすいと思いました
Task.create(task_params) は migrate したモデル名.に作ります.task_params(:name, :is_done)をと読める
ということはフロントから送られてきた情報をもとに db のテーブルに挿入する(permit て制限つきの)
head とは応答ステータスとヘッダ情報のみを表示らしい以下 option

- :ok 200 成功
- :created 201 リソースの生成に成功
- :moved_permanently 301 リソースが永続的にリダイレクト
- :found 302 リソースが一時的にリダイレクト
- など

---

```
  def destroy
    task = Task.find(params[:id])
    task.destroy
    head :ok
  end
```

rails では delete ではなく destroy
.find は上記にもあるが基本探すのような意味
ここの params は params[:カラム名]
なので受け取った:id を Task から探すといったような意味
それを task に格納し.destroy で削除
:ok **成功**

---

```
  def update
    task = Task.find(params[:id])
    task.update(task_params)
    head :ok
  end
```

create とほぼ同じ

### React

react18 では create-react-app で作成した index.jsx(tsx)を下記のように書き直すのが推奨
2022/7/22 現在では vite が 3 になり vite で作成すると書き換えの必要がなかった(別プロジェクトで発見)

```
import React from "react";
import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App";

const container = document.getElementById("root");
const root = createRoot(container);
root.render(
  <App />
);

```

今回フェッチングは axios で行った

```
const [tasks, setTasks] = useState([]);
 const fetch = async () => {
    const res = await axios.get("http://localhost:3010/tasks");
    setTasks(res.data);
  };

  const createTask = async () => {
    await axios.post("http://localhost:3010/tasks", {
      name: name,
      is_done: false,
    });
    setName("");
    fetch();
  };

  const destroyTask = async (id) => {
    await axios.delete(`http://localhost:3010/tasks/${id}`);
    fetch();
  };

  useEffect(() => {
    fetch();
  }, []);

  const toggleIsDone = async (id, index) => {
    const isDone = tasks[index].is_done;
    await axios.put(`http://localhost:3010/tasks/${id}`, {
      is_done: !isDone,
    });
    fetch();
  };
```

のようになった rails のための練習だったため react は知っていることが多かったので今回は書かないこととする
