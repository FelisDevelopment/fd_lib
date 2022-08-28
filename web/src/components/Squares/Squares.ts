import { range, shuffle, random } from '../../utils'

export interface GeneratedMinigame {
	realNumbers: number[]
	impostorNumbers: number[]
	groups: { [key: string]: any }[]
	quiz1: { [key: string]: any }
	quiz2: { [key: string]: any }
	solution: string
}

export class Squares {
	private static shapes: string[] = ['square', 'rectangle', 'circle', 'triangle']
	private static innerShapes: string[] = ['square', 'square2', 'rectangle', 'rectangle2', 'circle', 'circle2', 'triangle']
	private static colors: string[] = ['blue', 'green', 'red', 'orange', 'yellow', 'purple', 'black', 'white']
	private static types: { [key: string]: string }[] = [
		{ type: 'background_color', text: 'BACKGROUND COLOR' },
		{ type: 'number_color', text: 'NUMBER COLOR' },
		// Shape
		{ type: 'shape', text: 'SHAPE' },
		{ type: 'shape_color', text: 'SHAPE COLOR' },
		// Inner shape
		{ type: 'inner_shape', text: 'INNER SHAPE' },
		{ type: 'inner_shape_color', text: 'INNER SHAPE COLOR' },
		// Upper text - Color
		{ type: 'text_color', text: 'TEXT COLOR' },
		{ type: 'text_color_bg_color', text: 'COLOR TEXT BACKGROUND COLOR' },
		// Bottom text - Shape
		{ type: 'text_shape', text: 'SHAPE TEXT' },
		{ type: 'text_shape_bg_color', text: 'SHAPE TEXT BACKGROUND COLOR' },
	]

	static generate(squares: number): GeneratedMinigame {
		let realNumbers: number[]
		let impostorNumbers: number[]
		let minigame: GeneratedMinigame
		let group: { [key: string]: any }
		let backgroundColors: string[]
		let textColors: string[]
		let types: { [key: string]: string }[]
		let quizNumbers: number[]

		realNumbers = shuffle(range(1, squares))
		impostorNumbers = shuffle(range(1, squares))

		minigame = {
			realNumbers: [],
			impostorNumbers: [],
			groups: [],
			quiz1: {},
			quiz2: {},
			solution: '',
		}

		minigame.realNumbers = realNumbers
		minigame.impostorNumbers = impostorNumbers
		minigame.groups = []

		for (let i = 0; i < squares; i++) {
			group = {}

			backgroundColors = shuffle([...this.colors])
			textColors = shuffle([...this.colors])

			group['real_number'] = realNumbers[i]
			group['impostor_number'] = impostorNumbers[i]

			group['background_color'] = backgroundColors[0]
			group['number_color'] = this.colors[random(0, this.colors.length)]

			group['shape'] = this.shapes[random(0, this.shapes.length)]
			group['shape_color'] = backgroundColors[1]

			group['inner_shape'] = this.innerShapes[random(0, this.innerShapes.length)]
			group['inner_shape_color'] = backgroundColors[2]

			group['text_color'] = this.colors[random(0, this.colors.length)]
			group['text_color_bg_color'] = textColors[0]

			group['text_shape'] = this.shapes[random(0, this.shapes.length)]
			group['text_shape_bg_color'] = textColors[1]

			JSON.stringify(group)
			minigame['groups'].push(group)
		}

		quizNumbers = shuffle(range(0, squares - 1))
		types = shuffle([...this.types])

		let solution1 = minigame['groups'][quizNumbers[0]][types[0]['type']]
		let solution2 = minigame['groups'][quizNumbers[1]][types[1]['type']]
		solution1 = solution1.replace(/\d/, '')
		solution2 = solution2.replace(/\d/, '')

		minigame.quiz1 = {
			pos: quizNumbers[0],
			type: types[0],
			solution: solution1,
		}

		minigame.quiz2 = {
			pos: quizNumbers[1],
			type: types[1],
			solution: solution2,
		}

		minigame.solution = solution1 + ' ' + solution2

		return minigame
	}
}
