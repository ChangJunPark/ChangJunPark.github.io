---
layout: post
title: Git 브랜치 관련 명령어 모음
published: false
---

###### 맨날 까먹는 Git Branch 생성, 수정, 삭제 관련 명령어 모음

###### 이제는 제발 까먹지 말자

### remote에 있는 branch 목록 보기
```bash
$ gitbranch -r
  origin/HEAD -> origin/master
  origin/develop
  origin/master
```

### local에 있는 branch 목록 보기
```bash
$ git branch -l
* master
```

### local, remote에 있는 모든 branch 목록 보기
```bash
$ git branch -a
* master
  remotes/origin/HEAD -> origin/master
  remotes/origin/develop
  remotes/origin/master
```
### local에 새로운 branch 만들기
```bash
$ git checkout -b feature-working-with-dbs
```
또는
```bash
git branch feature-working-with-dbs
```

 

### local에 만들었던 branch 삭제하기
```bash
$ git checkout master 
'(삭제 대상이 아닌 다른 branch로 이동 필요)
```
```bash
$ git branch -D feature-working-with-dbs
```

### local에 있는 branch를 remote로 저장하기
```bash
$ git push origin origin:refs/heads/new-feature
```
또는 
```bash
$ git push origin deveolp 
```


### remote에 있었던 branch 를 local로 다운받기
```bash
$ git checkout feature-working-with-dbs
```

### remote에 있던 branch 삭제
```bash
$ git push origin :heads/feature-working-with-dbs
```
⤓

* * *

출처: [김용환님 블로그]( http://knight76.tistory.com/entry/Git-brancg-자주-사용하는-명령어)
