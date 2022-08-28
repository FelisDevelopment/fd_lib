<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" @keyup="keyPressed" ref="minigameWrapper" tabindex="0" v-if="apps.keysMinigame">
			<div :class="$style.splash" ref="splashWrapper">
				<div class="fa" :class="$style.hacker">&#xf11c;</div>
				<span :class="$style.text" class="block" ref="text"></span>
			</div>
			<div class="hidden" :class="$style.hack" ref="hackWrapper">
				<div :class="$style.bar"></div>
				<div :class="$style.letters" ref="letters"></div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, useCssModule } from 'vue'
import { waitFor, random } from '../utils'
//@ts-ignore-next-line
import mojs from '@mojs/core'

import { useAxios } from '@vueuse/integrations/useAxios'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

const resource: string | undefined = inject('resource')

function initialData() {
	return {
		gameStarted: false,
		model: '',
		difficulty: {
			easy: ['asd', 2000, 1000, 'easy'],
			medium: ['asdjkl', 1500, 750, 'medium'],
			hard: ['awsdgjikl', 1200, 500, 'hard'],
		},
		letters: [],
		validKeys: [],
		lettersPushed: 0,
		wrong: 0,
		right: 0,
	}
}

let minigameWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let splashWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let hackWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let letters: HTMLDivElement = $ref<HTMLDivElement>()
let text: HTMLSpanElement = $ref<HTMLSpanElement>()

let minigame = $ref<{ [key: string]: any }>(initialData())
let data = $ref<{ [key: string]: any }>({
	difficulty: 'easy',
	total: 10,
	tolerance: 2,
})

function keyPressed(event: KeyboardEvent) {
	const keyPressed = event.key.toLocaleLowerCase()

	if (minigame.gameStarted && minigame.validKeys.includes(keyPressed)) {
		let element = minigame.letters[0].el

		let top = -590 * element.dataset.progress
		if (top < -475 && top > -580 && keyPressed === element.textContent) {
			minigame.letters[0].el.classList.add(classes.green)
			minigame.right++
		} else {
			minigame.letters[0].el.classList.add(classes.red)
			minigame.wrong++
		}

		minigame.letters[0].stop()

		new mojs.Html({
			el: element,
			y: top,
			opacity: {
				1: 0,
				duration: 500,
			},
			duration: 500,
			onComplete() {
				element.remove()
			},
		}).play()

		minigame.letters.splice(0, 1)
	}
}

function ensureFocus() {
	minigameWrapper.focus()
}

function reset() {
	hackWrapper.classList.add('hidden')
	splashWrapper.classList.remove('hidden')
}

async function failed() {
	text.innerText = locale.t('system_didnt_accept_answer')

	await waitFor(2000)
	apps.keysMinigame = false

	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

async function success() {
	text.innerText = locale.t('system_bypassed')

	await waitFor(2000)
	apps.keysMinigame = false

	useAxios(`https://${resource}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}

function check() {
	minigame.gameStarted = false

	clearInterval(minigame.timerGame)
	clearInterval(minigame.ensureFocus)

	if (minigame.wrong > data.tolerance) {
		reset()
		failed()

		return
	}

	success()
	reset()
}

function createLetter() {
	if (!minigame.gameStarted) return

	if (minigame.lettersPushed >= data.total && minigame.letters.length === 0) {
		check()
		return
	}

	if (minigame.lettersPushed >= data.total) {
		return
	}

	let pos = random(1, 4)

	let div = document.createElement('div')
	div.classList.add(classes.letter, classes[`pos${pos}`])
	div.innerHTML = data.difficulty[0].charAt(random(0, data.difficulty[0].length - 1))
	letters.append(div)

	let duration = data.difficulty[1]
	let lettersCnt = minigame.letters.length

	minigame.lettersPushed++

	minigame.letters.push(
		new mojs.Html({
			el: div,
			y: {
				0: -590,
				duration: duration,
				easing: 'linear.none',
				onProgress(p: string) {
					div.dataset.progress = p
				},
			},
			opacity: {
				0: 1,
				duration: 200,
				easing: 'linear.none',
			},
			duration: duration,
			onComplete() {
				minigame.wrong++
				div.classList.add(classes.red)
				minigame.letters.splice(0, 1)
			},
			onUpdate() {
				if (this.gameStarted === false) this.pause()
			},
		})
	)

	minigame.letters[lettersCnt]
		.then({
			opacity: 0,
			duration: 500,
			onComplete() {
				div.remove()
			},
		})
		.play()
}

async function start() {
	apps.keysMinigame = true

	await waitFor(100)
	text.innerHTML = locale.t('pattern_recognition')

	await waitFor(1000)

	splashWrapper.classList.add('hidden')
	hackWrapper.classList.remove('hidden')

	data.difficulty = minigame.difficulty[data.difficulty] || minigame.difficulty['easy']
	minigame.validKeys = data.difficulty[0].split('')
	minigame.letters = []

	minigame.gameStarted = true

	minigame.timerGame = setInterval(createLetter, data.difficulty[2])
	minigame.ensureFocus = setInterval(ensureFocus, 1000)
}

emitter.on('keysMinigame:open', (event: any) => {
	data = event

	start()
})

emitter.on('keysMinigame:close', (event: any) => {
	apps.keysMinigame = false

	clearInterval(minigame.timerGame)
	clearInterval(minigame.ensureFocus)

	reset()
})
</script>

<style module>
.minigame {
	@apply relative m-[0_auto_20px] h-[640px] max-h-[640px] min-h-[640px] w-[640px] min-w-[640px] max-w-[640px] rounded-md bg-base-300/90 p-[0] outline-none focus:outline-none;
}
.splash {
	@apply mt-[240px] inline-block w-full text-center text-[16px] text-base-content;
}
.splash .hacker {
	@apply mb-[30px] text-[65px];
}
.minigame > .hack > .bar {
	@apply absolute mt-[64px] inline h-[64px] w-full bg-success/50;
}
.minigame .letters {
	@apply absolute;
}

.minigame .letter {
	@apply absolute top-[590px] text-[60px] uppercase text-base-content;
}
.letters .letter.pos1 {
	@apply ml-[60px];
}
.letters .letter.pos2 {
	@apply ml-[220px];
}
.letters .letter.pos3 {
	@apply ml-[387px];
}
.letters .letter.pos4 {
	@apply ml-[540px];
}
.letters .letter.red {
	@apply text-error;
}
.letters .letter.green {
	@apply text-success;
}
</style>
