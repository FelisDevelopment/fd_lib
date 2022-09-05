<template>
	<transition
		enter-active-class="duration-300 ease-out"
		enter-from-class="transform opacity-0"
		enter-to-class="opacity-100"
		leave-active-class="duration-200 ease-in"
		leave-from-class="opacity-100"
		leave-to-class="transform opacity-0"
	>
		<div :class="$style.minigame" ref="minigameWrapper" v-if="apps.squareMinigame">
			<div :class="$style.splash" ref="splashWrapper">
				<div class="fa" :class="$style.hacker" ref="icon">&#xf21b;</div>
				<span :class="$style.message" ref="message"></span>
				<audio preload="auto" ref="audioSplash">
					<source src="@/assets/audio_splash.ogg" type="audio/ogg" />
				</audio>
			</div>
			<div :class="$style.groups" class="hidden" ref="groupsWrapper">
				<div :class="[$style.group, $style[`bg_${group.background_color}`]]" v-for="(group, index) in generated?.groups" :key="group.real_number">
					<div :class="$style.real_number" :style="group?.style">{{ group.real_number }}</div>
					<div :class="[$style.shape, $style[group.shape], $style[`bg_${group.shape_color}`]]" class="hidden"></div>
					<div :class="[$style.text_color, $style[`txt_${group.text_color_bg_color}`]]" class="hidden">{{ locale.t(group.text_color) }}</div>
					<div :class="[$style.text_shape, $style[`txt_${group.text_shape_bg_color}`]]" class="hidden">{{ locale.t(group.text_shape) }}</div>
					<div :class="[$style.inner_shape, $style[group.inner_shape], $style[`bg_${group.inner_shape_color}`]]" class="hidden"></div>
					<div :class="[$style.number, $style[`txt_${group.number_color}`]]" class="hidden">{{ group.impostor_number }}</div>
				</div>
			</div>
			<div :class="$style.timer" class="hidden" ref="timer">
				<div :class="[$style.progress, $style.active]"><div :class="[$style.progressBar, $style.timerProgress]" ref="progressBar"></div></div>
				<audio preload="auto" loop ref="audioTimer">
					<source src="@/assets/audio_timer.ogg" type="audio/ogg" />
				</audio>
			</div>
			<div :class="$style.solution" class="hidden" ref="solutionWrapper">
				{{ locale.t('realNumbers') }}: <span class="real_numbers" ref="solutionNumbers">&nbsp;</span><br />
				{{ locale.t('solution') }}: <span class="solution_text" ref="solutionText">&nbsp;</span>
			</div>
			<div :class="$style.question" class="hidden" ref="quizWrapper">
				{{ locale.t('enter_the')?.toLocaleUpperCase() }} <span class="quiz1" ref="firstQuiz">$nbsp;</span> {{ locale.t('and')?.toLocaleUpperCase() }}
				<span class="quiz2" ref="secondQuiz">$nbsp;</span>
			</div>
			<div :class="$style.answer" class="hidden" ref="answerWrapper">
				<div :class="$style.answerWrapper" ref="secondAnswerWrapper">
					<label for="answer">{{ locale.t('answer') }}</label>
					<input
						type="text"
						:class="$style.answerInput"
						autocomplete="off"
						:placeholder="locale.t('squares_placeholder')"
						v-model="minigame.model"
						autofocus
						ref="input"
						@keyup.enter="check()"
						@input="invertTyping()"
					/>
				</div>
			</div>
		</div>
	</transition>
</template>
<script setup lang="ts">
import { inject, useCssModule } from 'vue'
import { waitFor } from '../utils'
import { Squares, type GeneratedMinigame } from './Squares/Squares'

import { useAxios } from '@vueuse/integrations/useAxios'

import { resource } from '@/utils'

import { useApp } from '@/stores/app'
import { useLocale } from '@/stores/locale'

const classes = useCssModule()
const emitter: any = inject('emitter')

const locale = useLocale()
const { apps } = useApp()

function initialData() {
	return {
		gameStarted: false,
		model: '',
		timerGame: null,
	}
}

let splashWrapper: HTMLDivElement = $ref<HTMLDivElement>()

let icon: HTMLDivElement = $ref<HTMLDivElement>()
let message: HTMLSpanElement = $ref<HTMLSpanElement>()
let audioSplash: HTMLAudioElement = $ref<HTMLAudioElement>()
let audioTimer: HTMLAudioElement = $ref<HTMLAudioElement>()
let input: HTMLInputElement = $ref<HTMLInputElement>()

let minigameWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let solutionWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let secondAnswerWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let groupsWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let answerWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let quizWrapper: HTMLDivElement = $ref<HTMLDivElement>()
let solutionNumbers: HTMLSpanElement = $ref<HTMLSpanElement>()
let solutionText: HTMLSpanElement = $ref<HTMLSpanElement>()
let firstQuiz: HTMLSpanElement = $ref<HTMLSpanElement>()
let secondQuiz: HTMLSpanElement = $ref<HTMLSpanElement>()
let progressBar: HTMLDivElement = $ref<HTMLDivElement>()
let timer: HTMLDivElement = $ref<HTMLDivElement>()

let minigame = $ref<{ [key: string]: any }>(initialData())
let generated = $ref<GeneratedMinigame>()
let data = $ref<{ [key: string]: any }>()

let splashScreen = (show = true) => {
	if (show) {
		minigameWrapper.querySelectorAll(`.${classes.groups}, .${classes.timer}, .${classes.question}, .${classes.answer}, .${classes.solution}`).forEach((el) => {
			el.classList.add('hidden')
		})

		splashWrapper.classList.remove('hidden')
	} else {
		splashWrapper.classList.add('hidden')
		groupsWrapper.querySelectorAll(classes.group).forEach((el) => {
			el.classList.remove('hidden')
		})
	}
}

function invertText() {
	groupsWrapper.querySelectorAll(`.${classes.group}`).forEach((el) => {
		if (Math.round(Math.random()) === 1 || Math.round(Math.random()) === 1) el.classList.toggle(classes.invert)
	})
}

function invertTyping() {
	if (minigame.gameStarted && data.invertTyping) {
		invertText()
	}
}

async function start() {
	generated = Squares.generate(data.squares)

	if (data?.inverted) {
		invertText()
	}

	if (data.hideQuestion) {
		quizWrapper.classList.remove('hidden')
	}

	firstQuiz.innerHTML = locale.t(generated.quiz1.type.type) + ' (' + generated.realNumbers[generated.quiz1.pos] + ')'
	secondQuiz.innerHTML = locale.t(generated.quiz2.type.type) + ' (' + generated.realNumbers[generated.quiz2.pos] + ')'

	solutionNumbers.innerHTML = generated.realNumbers.join(' ')
	solutionText.innerHTML = `${locale.t(generated.quiz1.solution)} ${locale.t(generated.quiz2.solution)}`

	await waitFor(1000)
	generated?.groups.forEach((group, index) => {
		generated.groups[index].style = {
			fontSize: '0px',
		}
	})

	await waitFor(2000)
	minigame.gameStarted = true

	generated?.groups.forEach((group, index) => {
		generated.groups[index].style = {
			display: 'none',
		}
	})

	groupsWrapper.querySelectorAll(`.${classes.group} > div`).forEach((el) => {
		el.classList.remove('hidden')
	})
	answerWrapper.classList.remove('hidden')
	quizWrapper.classList.remove('hidden')

	timer.classList.remove('hidden')

	if (data.hideQuestion) {
		quizWrapper.classList.add('hidden')
	}

	if (!data.hideQuestion) {
		quizWrapper.classList.remove('hidden')
	}

	audioTimer.play()
	input.focus({
		preventScroll: true,
	})

	progressBar.style.transitionDuration = `${data.duration / 1000}s`

	await waitFor(100)
	progressBar.style.width = '0px'

	if (data.debug) {
		solutionWrapper.classList.remove('hidden')
	}

	minigame.timerGame = setTimeout(() => {
		check()
	}, data.duration)
}

async function check() {
	minigame.gameStarted = false

	clearTimeout(minigame.timerGame)
	audioTimer.pause()

	const localizedAnswer = `${locale.t(generated?.quiz1.solution)} ${locale.t(generated?.quiz2.solution)}`.toLowerCase()

	if (localizedAnswer === minigame.model.toLowerCase()) {
		splashScreen()
		icon.innerHTML = '&#xf21b;'
		message.innerHTML = locale.t('system_bypassed')

		await waitFor(2000)

		reset()
		success()

		return
	}

	splashScreen()
	icon.innerHTML = '&#xf05e;'
	message.innerHTML = locale.t('system_didnt_accept_answer')

	await waitFor(2000)
	reset()
	failed()
}

function reset() {
	apps.squareMinigame = false
	audioSplash.pause()
	audioSplash.currentTime = 0

	audioTimer.pause()
	audioTimer.currentTime = 0
	minigameWrapper.querySelectorAll(`.${classes.group} > div, .${classes.timer}, .${classes.question}, .${classes.answer}, .${classes.solution}`).forEach((el) => {
		el.classList.add('hidden')
	})

	minigameWrapper.querySelectorAll(`.${classes.real_number}`).forEach((el) => {
		el.classList.remove('hidden')
	})

	if (!solutionWrapper.classList.contains('hidden')) {
		solutionWrapper.classList.add('hidden')
	}
	solutionWrapper.classList.add('hidden')

	progressBar.style.width = '100%'

	minigame = initialData()
}

function failed() {
	useAxios(`https://${resource()}/minigameResult`, {
		method: 'POST',
		data: {
			passed: false,
		},
	})
}

function success() {
	useAxios(`https://${resource()}/minigameResult`, {
		method: 'POST',
		data: {
			passed: true,
		},
	})
}

async function init() {
	apps.squareMinigame = true
	await waitFor(100)

	minigame = initialData()
	splashScreen()

	icon.innerHTML = '&#xf21b;'
	message.innerText = locale.t('booting_up')

	await waitFor(3000)
	message.innerText = locale.t('dialing')
	audioSplash.play()

	await waitFor(8000)
	message.innerText = locale.t('establishing_connection')

	await waitFor(6000)
	message.innerText = locale.t('doing_some_stuff')

	await waitFor(6000)
	message.innerText = locale.t('access_flagged')

	await waitFor(6000)
	splashWrapper.classList.add('hidden')
	groupsWrapper.classList.remove('hidden')

	start()
}

emitter.on('squareMinigame:open', (event: any) => {
	data = event

	init()
})

emitter.on('squareMinigame:close', (event: any) => {
	apps.squareMinigame = false

	splashScreen()
	reset()
})
</script>
<style module>
.minigame {
	@apply relative m-[0_auto_20px] h-[756px] max-h-[756px] min-h-[756px] min-w-[1280px] rounded-md bg-base-300/90;
}

.splash {
	@apply m-[310px_auto] inline-block w-full text-center text-[16px] text-base-content;
}
.splash .hacker {
	@apply mb-[30px] text-[65px];
}
.splash .message {
	@apply block text-[28px] font-bold;
}
.groups {
	@apply flex justify-evenly gap-3 px-3 pt-[130px];
}
.group {
	@apply relative h-[280px] w-[280px] border-[1px] border-neutral;
}
.group > div {
	@apply absolute;
}
.timer {
	@apply m-[135px_auto_35px_auto] h-[5px] w-full bg-base-100;
}
.timerProgress {
	@apply m-auto h-[5px] bg-primary;
}
.progressBar {
	@apply w-full transform border-t-[1px] border-b-[1px] border-neutral transition-[width] duration-[6s] ease-linear;
}
.real_number {
	@apply h-[280px] w-[280px] transform bg-neutral text-center align-middle text-[190px] leading-[280px] text-base-content transition-[font-size] duration-[2s] ease-linear;
}
.text_color,
.text_shape {
	@apply w-full text-center text-[31px] font-bold uppercase;
	font-family: 'arial black', sans-serif;
	-webkit-text-stroke: 1px black;
}
.text_color {
	@apply top-[82px];
}
.text_shape {
	@apply top-[158px];
}
.invert .text_color {
	@apply top-[158px];
}
.invert .text_shape {
	@apply top-[82px];
}
.number {
	@apply top-[100px] w-full text-center text-[82px] uppercase leading-[82px];
	-webkit-text-stroke: 1px black;
}

.txt_blue {
	@apply text-[#2195ee];
}
.txt_green {
	@apply text-[#4cae4f];
}
.txt_red {
	@apply text-[#7b0100];
	-webkit-text-stroke: 1px #ffffff;
}
.txt_orange {
	@apply text-[#fd9802];
}
.txt_yellow {
	@apply text-[#fceb3d];
}
.txt_purple {
	@apply text-[#9926ac];
}
.txt_black {
	@apply text-[#000000];
	-webkit-text-stroke: 1px #ffffff;
}
.txt_white {
	@apply text-[#ffffff];
}

.bg_blue {
	@apply bg-[#2195ee];
}
.bg_green {
	@apply bg-[#4cae4f];
}
.bg_red {
	@apply bg-[#7b0100];
}
.bg_orange {
	@apply bg-[#fd9802];
}
.bg_yellow {
	@apply bg-[#fceb3d];
}
.bg_purple {
	@apply bg-[#9926ac];
}
.bg_black {
	@apply bg-[#000000];
}
.bg_white {
	@apply bg-[#ffffff];
}

.square {
	@apply m-[32px_auto_auto_32px] h-[215px] w-[215px] border-[1px] border-black;
}
.inner_shape.square {
	@apply m-[114px_auto_auto_112px] h-[52px] w-[50px];
}
.inner_shape.square2 {
	@apply m-[124px_auto_auto_112px] h-[44px] w-[54px] border-[1px] border-black;
}
.rectangle {
	@apply m-[75px_auto_auto_32px] h-[128px] w-[216px] border-[1px] border-black;
}
.inner_shape.rectangle {
	@apply m-[114px_auto_auto_87px] h-[52px] w-[106px];
}
.inner_shape.rectangle2 {
	@apply m-[124px_auto_auto_87px] h-[32px] w-[106px] border-[1px] border-black;
}
.triangle {
	@apply mask mask-triangle m-[32px_auto_auto_32px] h-[215px] w-[215px] bg-black;
}
.triangle:before {
	content: '';
	@apply mask mask-triangle absolute m-[1px] h-[213px] w-[213px];
}
.inner_shape.triangle {
	@apply m-[104px_auto_auto_104px] h-[72px] w-[72px];
}
.inner_shape.triangle:before {
	@apply h-[70px] w-[70px];
}
.triangle.bg_blue:before {
	@apply bg-[#2195ee];
}
.triangle.bg_green:before {
	@apply bg-[#4cae4f];
}
.triangle.bg_red:before {
	@apply bg-[#7b0100];
}
.triangle.bg_orange:before {
	@apply bg-[#fd9802];
}
.triangle.bg_yellow:before {
	@apply bg-[#fceb3d];
}
.triangle.bg_purple:before {
	@apply bg-[#9926ac];
}
.triangle.bg_black:before {
	@apply bg-[#000000];
}
.triangle.bg_white:before {
	@apply bg-[#ffffff];
}
.circle {
	@apply mask mask-circle m-[31px_auto_auto_31px] h-[218px] w-[218px] bg-black;
}
.circle:before {
	content: '';
	@apply mask mask-circle absolute h-[218px] w-[218px];
}
.inner_shape.circle {
	@apply mask mask-circle m-[112px_auto_auto_112px] h-[58px] w-[58px];
}
.inner_shape.circle:before {
	@apply mask mask-circle h-[58px] w-[58px];
}
.inner_shape.circle2 {
	@apply m-[112px_auto_auto_112px] h-[58px] w-[58px] bg-black;
	clip-path: ellipse(27px 17px);
}
.inner_shape.circle2:before {
	content: '';
	@apply absolute h-[58px] w-[58px];
	clip-path: ellipse(26px 16px);
}
.circle.bg_blue:before,
.circle2.bg_blue:before {
	@apply bg-[#2195ee];
}
.circle.bg_green:before,
.circle2.bg_green:before {
	@apply bg-[#4cae4f];
}
.circle.bg_red:before,
.circle2.bg_red:before {
	@apply bg-[#7b0100];
}
.circle.bg_orange:before,
.circle2.bg_orange:before {
	@apply bg-[#fd9802];
}
.circle.bg_yellow:before,
.circle2.bg_yellow:before {
	@apply bg-[#fceb3d];
}
.circle.bg_purple:before,
.circle2.bg_purple:before {
	@apply bg-[#9926ac];
}
.circle.bg_black:before,
.circle2.bg_black:before {
	@apply bg-[#000000];
}
.circle.bg_white:before,
.circle2.bg_white:before {
	@apply bg-[#ffffff];
}

.question {
	@apply absolute bottom-[146px] w-full text-center text-[20px] font-bold uppercase text-base-content;
}
.answer {
	@apply absolute bottom-[24px] w-full text-center text-[20px] font-bold text-base-content;
}
.answer label {
	@apply mb-[8px] block text-left text-[12px];
}
.answerWrapper {
	@apply relative inline-block w-[222px] text-base-content;
}
.answerWrapper:after {
	font-family: 'Font Awesome 5 Free', sans-serif;
	content: '\f21b';
	@apply absolute left-[3px] top-[25px] text-[18px];
}
.answerInput {
	@apply w-full border-b-[2px] border-neutral bg-transparent p-[0_0_6px_28px] text-[15px] font-bold text-base-content;
}
.answerInput::placeholder {
	@apply text-base-content;
}
.answerInput:focus {
	@apply outline-none;
}

.solution {
	@apply m-[-150px_auto_auto] w-[-moz-fit-content] w-[fit-content] rounded-[18px] bg-success p-[20px] text-center text-[20px] font-bold uppercase text-success-content;
}
</style>
