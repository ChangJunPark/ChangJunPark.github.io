---
layout: post
title: 모던 C 프로그래밍 정리
---

[TOC]

# 1. 주분투에 이클립스 설치

이건 생략

# 2. 이클립스 기본 사용법

##2.1 run
 - Ctrl+F11

##2.2 debug
 - breakpoint
 - 특정 조건이 성립햇을 때 정지하기 (Breakpoint Properties..  --> Condition)
 - 특정 위치가 n번째로 실행되면 정지하기 (Breakpoint Properties..  --> Ignore Count)
 - 변수의 값 변경 (Variables --> Value 편집)

##2.3 jump
 - jump to define (F3)
 - open call hierarchy (Ctrl+Alt+H)
 - 뒤로가기 앞으로 가기 (alt + 방향키)

##2.4 content assist 자동완성 (Alt + /)

##2.5 Macro analysis (Ctrl + =)

# 3. C and OOP

##3.1 Stack을 통한 C의 모듈화와 객체지향
고전적인 스택 구현


``` cpp
#ifndef _STACK_H_
#define _STACK_H_

#ifdef __cplusplus
extern "C" {
#endif

bool push(int val);
bool pop(int *pRet);

#ifdef __cplusplus
}
#endif

#endif

```
[코드 3-01 stack.h] 고전적 stack

```cpp
#include <stdbool.h>
#include "stack.h"

int buf[16];
int top = 0;

bool isStackFull(void) {
  return top == sizeof(buf) / sizeof(int);
}

bool isStackEmpty(void) {
  return top == 0;
}

// true: 成功, false: 失敗
bool push(int val) {
    if (isStackFull()) return false;
    buf[top++] = val;
    return true;
}

// true: 成功, false: 失敗
bool pop(int *pRet) {
    if (isStackEmpty()) return false;
    *pRet = buf[--top];
    return true;
}

```
[코드 3-02 stack.c] 고전적 stack
```
C++ 주석    	: //이후에 오는 내용은 행의 마지막까지 주석으로 처리
bool type 	 : stdbool.h에서 bool, true, false 사용가능
변수 선언 위치	: C99에서는 변수가 사용되는 직넌위치에 변수를 선언함으로서 스코프를 제한할 수 있음
```


### 문제점 --> 변수와 함수의 스코프
 - push()와 pop()이 노출되어 있어야 함
 - 하지만 buf, top, isStackFull, isStackEmpty 가 전역 namespase에 공개되어있음
 - 다른 소스코드에도 동일한 이름의 변수와 함수가 있을 시 충돌로 link error 발생
 - 위 이유로 다른 프로그램의 부품으로 사용하기 힘듦

### 해결법 --> static 사용
```cpp
#include <stdbool.h>
#include "stack.h"

static int buf[16];
static int top = 0;

static bool isStackFull(void) {
  return top == sizeof(buf) / sizeof(int);
}

static bool isStackEmpty(void) {
  return top == 0;
}

// true: 成功, false: 失敗
bool push(int val) {
    if (isStackFull()) return false;
    buf[top++] = val;
    return true;
}

// true: 成功, false: 失敗
bool pop(int *pRet) {
    if (isStackEmpty()) return false;
    *pRet = buf[--top];
    return true;
}

```
[코드 3-03 stack.c] static으로 해결
 - static 지시자를 붙여 namespase 구분
 - 외부에 공개하지 않을 함수, 변수에는 static 지시자를 붙여 캡슐화 시킴

##3.2 구조체를 이용한 자료구조와 로직의 분리

### 코드 3-03에서의 문제점
 - 하나의 Stack밖에 사용 못함 --> 해결책:
 	- 이름을 바꿔가며 사용하기
 	- struct 사용

```cpp
#ifndef _STACK_H_
#define _STACK_H_

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _stack{
	int top;
	const size_t size;
	int *const pBuf;
}Stack;

bool push(int val);
bool pop(int *pRet);

/* 생성자 같은 macro
   int buf[16];
   Stack stack = newStack(buf);

   는 매크로 확장을 통해

   int buf[16];
   Stack stack = { 0, sizeof(buf)/sizeof(int), (buf) };
*/
#define newStack(buf){ 0, sizeof(buf)/sizeof(int), (buf) }

#ifdef __cplusplus
}
#endif

#endif
```
[코드 3-04 stack.h] 구조채를 이용하여 여러개의 stack을 갖도록 하기

```cpp
#include <stdbool.h>
#include "stack.h"

static bool isStackFull(const Stack *p) {
  return p->top == p->size;
}

bool isStackEmpty(const Stack *p) {
  return p->top == 0;
}

// true: 成功, false: 失敗
bool push(Stack *p, int val) {
    if (isStackFull(p)) return false;
    p->pBuf[p->top] = val;
    return true;
}

// true: 成功, false: 失敗
bool pop(Stack *p, int *pRet) {
    if (isStackEmpty(p)) return false;
    *pRet = p->pBuf[--(p->top)];
    return true;
}
```
[코드 3-05 stack.c] 구조채를 이용하여 여러개의 stack을 갖도록 하기

- 구초제를 쉽게 초기화 하기 위해 newStack 매크로 정의
```
   int buf[16];
   Stack stack = newStack(buf);

   는 매크로 확장을 통해향

   int buf[16];
   Stack stack = { 0, sizeof(buf)/sizeof(int), (buf) };
```
- 구조체를 이용함으로써 스택 구조는 독립적으로 비뀜
- 부품으로도 충분히 사용 가능한 수준에 도달함

##3.3 C를 이용한 객체 지향

#### 범위 검사 기능을 가진 스택
스택에 푸시할때 해당 범위만 가려서 푸시하기
```cpp
bool pushWithRangeCheck(Stack *p, int val, int min, int max){
	if(vla < min || val > max) return false;
	return push(p,val);
}
```
이렇게 할 수 있겠지만 파라미터도 많고 매번 min, max를 전달한다는건 번거로움.

그렇다면 객체지향이니 struct에 min max를 설정해 보면 어떨까??

```cpp
typedef struct _stack{
	int top;
	const size_t size;
	int * const pBuf; //다른 주소로 바뀔수 없도록 pBuf앞에 const키워드 사용

	const bool needRangeCheck;
	const int min;
	const int max;
} Stack;

...

#define newStack(buf) { 0,sizeof(buf)/sizeof(int), (buf), false, 0, 0}
#define newStackWithRangeCheck(buf, min, max) {\
				0, sizeof(buf)/sizeof(int), (buf), true, (min), (max)}
```
[코드 3-06 stack.h] 범위를 검사하는 stack

```cpp
static bool isRangeOk(const Stack *p, int val){
	return !p->needRangeChack || (p->min <= val && val <= p->max);
}

bool push (Stack *p, int val){
	if(!isRangeOk(p, val)||isStackFull(p)) return false;
	p->pBuf[p->top++] = val;
	return true;
}
```
[코드 3-06 stack.c] 범위를 검사하는 stack

이런식으로 말이다.

구조체에 needRangeCheck을 넣음으로서 기존 스택과 범위 검사 스택을 모두 사용하게끔 하였고, min, max를 구조체 맴버변수로 넣음으로서 constructor 역할을 하는 메크로에도 변동이 생겼다.

또한 isRangeOk함수를 통해 범위 검사를 수행하고 그 결과를 push안에서 해결함으로서 기존의 stack은 무리없이 작동함
`Stack stack = newStackWithRangeCheck(buf, 0, 9)` 
위의 코드는  0-9의 범위의 값을 저장하는 stack을 생성함

####위 [코드 3-06]의 문제점
 - 범위검사 기능이 없는 일반 스택을 생성한 경우에도 needRageCheck, min, max강느 불필요한 맴버를 스텍에 보유해야 함. (메모리 낭비 ㅠㅠ)
 - Stack에 또 다른 검사 기능을 추가하고 싶다면 구조체에 다른 맴버를 추가해야 함
```cpp
  typedef struct _stack{
  	int top;
	const size_t size;
	int * const pBuf;

	const bool needRangeCheck;
	const int min;
	const int max;
	
	...
	
	const bool need newCheck;
	const int something;
  }Stack;
```
[코드 3-07 stack.h의 일부] **++요구사항이 늘어남에 따라 커져가는 stack++**

 - 위와같이 계속 늘어나게 되면 구조체 내부에서 제공하는 기능에 필요한 모든 멤버를 가져야 하므로 push함수도 그 기능 때문에 크기가 커짐
 - 기능이 늘어나면 곧장 걷잡을 수 없을 만큼 복잡해 짐 (*이라고 써있지만 그냥 이미 복잡함..*)

####1차 수정 -> bool변수, min, max 분리


```cpp
typedef struct _range{
	const int min;
	const int max;
}Range;

typedef struct _stack{
	int top;
	const size_t size;
	int * const pBuf;

	//다른 주소로 바뀔수 없도록 pBuf앞에 const키워드 사용
	//Range 구조체의 값도 변경이 있으면 안되니까 Range 앞에 const 키워드 사용
	//... 어휴 헷갈린당
	const Range * const range;
} Stack;

...

//#define newStack(buf) { 0,sizeof(buf)/sizeof(int), (buf), false, 0, 0}
#define newStack(buf) { 0,sizeof(buf)/sizeof(int), (buf), NULL}

//#define newStackWithRangeCheck(buf, min, max) {0, sizeof(buf)/sizeof(int), (buf), true, (min), (max)}
#define newStackWithRangeCheck(buf, pRange) {0, sizeof(buf)/sizeof(int), (buf), (pRange)}
```
[코드 3-08 stack.h] 기능을 분리한 stack

```cpp
static bool isRangeOk(const Range *p, int val){
	return !(p != Null) || (p->min <= val && val <= p->max);
}

bool push (Stack *p, int val){
	if(!isRangeOk(p->pRange, val)||isStackFull(p)) return false;
	p->pBuf[p->top++] = val;
	return true;
}
```
[코드 3-08 stack.c] 기능을 분리한 stack

 - 다이어트 성공 ㅋㅋㅋ
 - 범위 검사에 필요한 데이터를 Range구조체로 옮기고 isRangeOk함수는 Range를 받아 판덩함
 - 스텍 데이터를 가진 Stack과 범위 검색을 위한 데이터를 가진 Range가 분리됨

####2차 수정 -> 체크 기능의 볌용화
상하 한계 검사이외에 직전 push된 값 이상의 값만 push 가능하도록 해보자.

먼저, Validator 라는 구조체에 입력값을 검사하는 범용적인 역할을 구현함

```cpp
typedef struct _validator{
	bool (* const validate)(struct _validator *pThis, int val);
	void * cost pData;
}Validator

typedef struct _range{
	const int min;
	const int max;
}Range;

typedef struct _previousvalue{
	int previousValue;
}PreviousValue;

.... //Validator 생성자
#define rangeValidator(pRange) { validateRange, pRange }
								// Vaidator.varedate = validateRange
								// Vaidator.pDate = pRange;

#define previousValidator(pPrevious) { validatePrevious, pPrevious }
								// Vaidator.varedate = validateRange
								// Vaidator.pDate = pPrevious;
....

typedef struct _stack{
	int top;
	const size_t size;
	int * const pBuf;

	Validator * const pValidator;
} Stack;

...

#define newStack(buf) { 0,sizeof(buf)/sizeof(int), (buf), NULL}

#define newStackWithRangeCheck(buf, pRange) {0, sizeof(buf)/sizeof(int), (buf), (pRange)}
```
[코드 3-09 stack.h] validator를 사용한 stack
```cpp
bool validateRange (Validator *pThis, int val){
	Range *pRange = pThis->data;
	return pRange->min <= val || val <= pRange->max
}
bool validatePrevious (Validator *pThis, int val){
	PreviousValue *pPrevious = pThis->data;
	if (pPrevioius->previousValue > val)
	return pPrevious->previousValue < val;
}

static bool isRangeOk(const Range *p, int val){
	return !(p != Null) || (p->min <= val && val <= p->max);
}

bool push (Stack *p, int val){
	if(!isRangeOk(p->pRange, val)||isStackFull(p)) return false;
	p->pBuf[p->top++] = val;
	return true;
}
```
[코드 3-09 stack.c] validator를 사용한 stack

 - Validator 구조체 내부의 첫번째 맴버를 함수포인터로 이 함수는 인자로 Validator 구조체를 가리키는 포인터와 검사할 값을 받아 검사결과를 vool로 반환
```cpp
typedef struct _validator{
	bool (* const validate)(struct _validator *pThis, int val);
	void * cost pData;
}Validator
```
 - 두번째 맴버 변수는 검사에 사용할 데이터 (Range -> min, max 등)
 - 이러한 데이터는 검사 종류에 따라 천차만별이므로 void 포인터의 형태로 지정하여 뭐든지 받아들이도록 함
```cpp
typedef struct _range{
		const int min;
		const int max;
}Range;
typedef struct _previousvalue{
		int previousValue;
}PreviousValue;
```
 - Range나 PreviousValue의 경우 pData에 대응되어 사용됨
```cpp
bool validateRange (Validator *pThis, int val){
		Range *pRange = pThis->data;
		return pRange->min <= val || val <= pRange->max
}
bool validatePrevious (Validator *pThis, int val){
		PreviousValue *pPrevious = pThis->data;
		if (pPrevioius->previousValue > val)
		return pPrevious->previousValue < val;
}
```
 - validateRange, validatePrevious의 경우 Validator->validate에 대응되어 사용됨
 - `#define newStackWithRangeCheck(buf, pRange) {0, sizeof(buf)/sizeof(int), (buf), (pRange)}` 로 생성

