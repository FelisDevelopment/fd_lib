export interface DialogData {
	header: string
	inputs: Input[]
	buttons: DialogButtons
}

export interface DialogButtons {
	close?: {
		label?: string
		classes?: string[]
	}
	submit?: {
		label: string
		classes?: string[]
	}
}

export interface Input {
	type: string
	label?: string
	value?: string | number | boolean | null
	options?: Options
}

export interface Options {
	[key: string]: string | number | boolean | string[] | {}
}

export interface InputTypes {
	[key: string]: any
}

export interface ContextButton {
	label: string
	classes?: string[]
}

export interface ContextSection {
	title?: string
	description?: string
	components?: Input[]
	submit?: boolean
	realIndex?: number
}

export interface ContextTab {
	label: string
	sections: ContextSection[]
	id?: string | number
	category?: string
	close?: any
}

export interface ContextData {
	tabs: ContextTab[]
	buttons: ContextButton[]
}
