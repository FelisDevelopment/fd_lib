<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" ref="minigameWrapper" v-if="apps.combinationMinigame">
			<div :class="$style.splash">
				<div class="fa" :class="$style.hacker">&#xf21b;</div>
				<span class="text block" ref="splashText">{{ locale.t('preparing_interface') }}</span>
			</div>
			<div class="hidden" :class="$style.hack" ref="hackWrapper">
				<div :class="$style.find" ref="findWrapper"></div>
				<div :class="$style.timer" ref="timerWrapper">00:00</div>
				<div :class="$style.codes" ref="codesWrapper"></div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, onMounted, useCssModule } from 'vue'
import { random, waitFor, shuffle } from '../utils'

import { useAxios } from '@vueuse/integrations/useAxios'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

const resource: string | undefined = inject('resource')

function initialData(): { [key: string]: any } {
	return {
		codesPos: 0,
		currentPos: 43,
		sets: [],
		available: ['numeric', 'alphabet', 'alphanumeric', 'greek', 'braille', 'runes'],
		codes: [],
	}
}

// Refs
let minigameWrapper = $ref<HTMLDivElement>()
let codesWrapper = $ref<HTMLDivElement>()
let hackWrapper = $ref<HTMLDivElement>()
let findWrapper = $ref<HTMLDivElement>()
let timerWrapper = $ref<HTMLDivElement>()
let splashText = $ref<HTMLSpanElement>()

let minigame = $ref(initialData())
let data = $ref<{ [key: string]: any }>()

function randomSetChar(): string {
	let str = '?'

	if (data.sets === 'random') {
		data.sets = minigame.available[random(0, minigame.available.length)]
	}

	switch (data.sets) {
		case 'numeric':
			str = '0123456789'
			break
		case 'alphabet':
			str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
			break
		case 'alphanumeric':
			str = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
			break
		case 'greek':
			str = 'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'
			break
		case 'braille':
			str =
				'⡀⡁⡂⡃⡄⡅⡆⡇⡈⡉⡊⡋⡌⡍⡎⡏⡐⡑⡒⡓⡔⡕⡖⡗⡘⡙⡚⡛⡜⡝⡞⡟⡠⡡⡢⡣⡤⡥⡦⡧⡨⡩⡪⡫⡬⡭⡮⡯⡰⡱⡲⡳⡴⡵⡶⡷⡸⡹⡺⡻⡼⡽⡾⡿' +
				'⢀⢁⢂⢃⢄⢅⢆⢇⢈⢉⢊⢋⢌⢍⢎⢏⢐⢑⢒⢓⢔⢕⢖⢗⢘⢙⢚⢛⢜⢝⢞⢟⢠⢡⢢⢣⢤⢥⢦⢧⢨⢩⢪⢫⢬⢭⢮⢯⢰⢱⢲⢳⢴⢵⢶⢷⢸⢹⢺⢻⢼⢽⢾⢿' +
				'⣀⣁⣂⣃⣄⣅⣆⣇⣈⣉⣊⣋⣌⣍⣎⣏⣐⣑⣒⣓⣔⣕⣖⣗⣘⣙⣚⣛⣜⣝⣞⣟⣠⣡⣢⣣⣤⣥⣦⣧⣨⣩⣪⣫⣬⣭⣮⣯⣰⣱⣲⣳⣴⣵⣶⣷⣸⣹⣺⣻⣼⣽⣾⣿'
			break
		case 'runes':
			//str="ᚠᚡᚢᚣᚤᚥᚦᚧᚨᚩᚪᚫᚬᚭᚮᚯᚰᚱᚲᚳᚴᚵᚶᚷᚸᚹᚺᚻᚼᚽᚾᚿᛀᛁᛂᛃᛄᛅᛆᛇᛈᛉᛊᛋᛌᛍᛎᛏᛐᛑᛒᛓᛔᛕᛖᛗᛘᛙᛚᛛᛜᛝᛞᛟᛠᛡᛢᛣᛤᛥᛦᛧᛨᛩᛪ";
			str = 'ᚠᚥᚧᚨᚩᚬᚭᚻᛐᛑᛒᛓᛔᛕᛖᛗᛘᛙᛚᛛᛜᛝᛞᛟᛤ'
			break
	}

	return str.charAt(random(0, str.length))
}

function ensureShowType() {
	switch (data.showType) {
		case 0:
			hackWrapper?.classList.remove(classes.mirrored)
			break
		case 1:
			if (Math.round(Math.random()) === 1) hackWrapper?.classList.add(classes.mirrored)
			else hackWrapper?.classList.remove(classes.mirrored)
			break
		case 2:
			hackWrapper?.classList.add(classes.mirrored)
			break
	}
}

function getGroupFromPos(pos: number, count: number = 4) {
	let group = [pos]
	for (let i = 1; i < count; i++) {
		if (pos + i >= 80) {
			group.push(pos + i - 80)
		} else {
			group.push(pos + i)
		}
	}
	return group
}

function drawPosition(className = 'text-error', deleteClass = true) {
	let toDraw = getGroupFromPos(minigame.currentPos)

	if (deleteClass) {
		codesWrapper.querySelectorAll(`div.${className}`).forEach((el) => {
			el.classList.remove(className)
		})
	}

	let codes = codesWrapper.querySelectorAll('div')
	toDraw.forEach((draw) => {
		if (draw < 0) draw = 80 + draw
		codes[draw].classList.add(className)
	})
}

function moveCodes() {
	minigame.codesPos++
	minigame.codesPos = minigame.codesPos % 80

	let codes_tmp = [...minigame.codes]
	for (let i = 0; i < minigame.codesPos; i++) {
		codes_tmp.push(codes_tmp[i])
	}
	codes_tmp.splice(0, minigame.codesPos)

	codesWrapper.innerHTML = ''
	for (let i = 0; i < 80; i++) {
		let div = document.createElement('div')
		div.innerHTML = codes_tmp[i]
		codesWrapper.append(div)
	}

	drawPosition()
}

function startTimer(timeout: number) {
	minigame.timerStarted = new Date()
	minigame.timerTime = setInterval(timer, 1, timeout)
}

function timer(timeout: number) {
	let timerNow: Date = new Date()
	let timerDiff: Date = new Date()

	timerDiff.setTime(timerNow.getTime() - minigame.timerStarted.getTime())

	let ms: number | string = timerDiff.getMilliseconds()
	let sec: number | string = timerDiff.getSeconds()
	if (ms < 10) {
		ms = '00' + ms
	} else if (ms < 100) {
		ms = '0' + ms
	}

	let ms2: number | string = 999 - +ms
	if (ms2 > 99) ms2 = Math.floor(ms2 / 10)
	if (ms2 < 10) ms2 = '0' + ms2

	sec = timeout / 1000 - 1 - sec

	if (sec <= 0 && ms2 <= 0) {
		sec = 0
		ms2 = 0
	}

	timerWrapper.innerHTML = `${sec}.${ms2}`
}

function stopTimer() {
	clearInterval(minigame.timerTime)
}

function resetTimer() {
	clearInterval(minigame.timerTime)
	timerWrapper.innerHTML = '0.000'
}

async function check() {
	stopTimer()

	let currentAttempt = minigame.currentPos + minigame.codesPos
	currentAttempt %= 80

	if (minigame.gameStarted && currentAttempt === minigame.correctPos) {
		drawPosition('text-success')
		await success()

		reset()
	} else {
		minigame.currentPos = minigame.correctPos - minigame.codesPos
		drawPosition('text-success', false)

		await failed()
		reset()
	}
}

async function success() {
	hackWrapper.classList.add('hidden')
	timerWrapper.innerHTML = ''
	splashText.innerHTML = locale.t('hack_success')

	await waitFor(2000)

	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}

async function failed() {
	hackWrapper.classList.add('hidden')
	timerWrapper.innerHTML = ''
	splashText.innerHTML = locale.t('hack_failed')

	await waitFor(2000)

	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

async function reset() {
	minigame.gameStarted = false
	apps.combinationMinigame = false

	resetTimer()
	clearInterval(minigame.timerStart)
	clearInterval(minigame.timerGame)
	clearTimeout(minigame.timerFinish)
	clearInterval(minigame.timerHide)
}

async function start() {
	splashText.innerHTML = locale.t('preparing_interface')
	minigame = initialData()

	if (Array.isArray(data.sets)) {
		;[data.sets] = shuffle(data.sets)
	}

	ensureShowType()

	minigame.codes = []
	for (let i = 0; i < 80; i++) {
		minigame.codes.push(randomSetChar() + randomSetChar())
	}

	minigame.correctPos = random(0, 80)

	minigame.toFind = getGroupFromPos(minigame.correctPos)
	minigame.toFind = `<div>${minigame.codes[minigame.toFind[0]]}</div><div>${minigame.codes[minigame.toFind[1]]}</div><div>${minigame.codes[minigame.toFind[2]]}</div><div>${
		minigame.codes[minigame.toFind[3]]
	}</div>`

	codesWrapper.innerHTML = ''
	for (let i = 0; i < 80; i++) {
		let div = document.createElement('div')
		div.innerHTML = minigame.codes[i]
		codesWrapper.append(div)
	}

	findWrapper.innerHTML = minigame.toFind

	drawPosition()

	await waitFor(1000)
	splashText.innerHTML = locale.t('connect_to_host')
	hackWrapper.classList.remove('hidden')

	minigame.timerGame = setInterval(moveCodes, 1500)

	minigame.gameStarted = true

	startTimer(data.duration)

	if (data.hideChars && random(1, 4) === 1) {
		minigame.timerHide = setInterval(function () {
			findWrapper.innerHTML = ''
		}, 3500)
	}

	minigame.timerFinish = setTimeout(() => {
		minigame.gameStarted = false
		check()
	}, data.duration)
}

onMounted(() => {
	document.addEventListener('keydown', function (ev) {
		let key_pressed = ev.key
		let valid_keys = ['a', 'w', 's', 'd', 'ArrowUp', 'ArrowDown', 'ArrowRight', 'ArrowLeft', 'Enter']

		if (minigame.gameStarted && valid_keys.includes(key_pressed)) {
			switch (key_pressed) {
				case 'w':
				case 'ArrowUp':
					minigame.currentPos -= 10
					if (minigame.currentPos < 0) minigame.currentPos += 80
					break
				case 's':
				case 'ArrowDown':
					minigame.currentPos += 10
					minigame.currentPos %= 80
					break
				case 'a':
				case 'ArrowLeft':
					minigame.currentPos--
					if (minigame.currentPos < 0) minigame.currentPos = 79
					break
				case 'd':
				case 'ArrowRight':
					minigame.currentPos++
					minigame.currentPos %= 80
					break
				case 'Enter':
					check()
					return
			}

			drawPosition()
		}
	})
})

emitter.on('combinationMinigame:open', (event: any) => {
	apps.combinationMinigame = true
	data = event

	setTimeout(() => {
		start()
	}, 1000)
})

emitter.on('combinationMinigame:close', (event: any) => {
	reset()
})
</script>
<style module>
.minigame {
	@apply m-[0_auto_20px] w-[540px] min-w-[540px] max-w-[540px] rounded-md bg-base-300/90 p-[30px_0];
}
.splash {
	@apply inline-block w-full text-center text-lg text-base-content;
}
.splash .hacker {
	@apply mb-[30px] text-[65px];
}
.splash .text {
	@apply font-bold;
}
.minigame .find {
	@apply mt-[10px] flex select-none items-center justify-center gap-3 text-center text-[30px] text-base-content;
}
/* .minigame .find > div {
	@apply flex gap-3;
} */
.minigame .timer {
	@apply mb-[15px] text-center text-[14px] text-success;
}
.minigame .codes {
	@apply m-[auto] flex w-[400px] flex-wrap;
}
.minigame .codes > div {
	@apply m-[7px_0] flex-[1_0_10%] transform text-center text-[18px];
}
div.red {
	@apply text-error;
}
.minigame .codes > div.green {
	@apply text-success;
}
.minigame .mirrored .find > div,
.minigame .mirrored .codes > div {
	-moz-transform: scale(-1, -1);
	-o-transform: scale(-1, -1);
	-webkit-transform: scale(-1, -1);
	transform: scale(-1, -1);
}
.restart {
	@apply text-center;
}
</style>
