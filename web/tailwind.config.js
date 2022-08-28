const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
	content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
	safelist: [
		{
			pattern: /./,
		},
	],
	theme: {
		extend: {
			fontFamily: {
				sans: ['Inter var', ...defaultTheme.fontFamily.sans],
				yan: ['Yantramanav', 'sans-serif'],
			},
			screens: {
				'2k': '1921px',
			},
		},
	},
	plugins: [require('@tailwindcss/typography'), require('daisyui')],
	daisyui: {
		themes: [
			'light',
			'dark',
			'cupcake',
			'bumblebee',
			'emerald',
			'corporate',
			'synthwave',
			'retro',
			'cyberpunk',
			'valentine',
			'halloween',
			'garden',
			'forest',
			'aqua',
			'lofi',
			'pastel',
			'fantasy',
			'wireframe',
			'black',
			'luxury',
			'dracula',
			'cmyk',
			'autumn',
			'business',
			'acid',
			'lemonade',
			'night',
			'coffee',
			'winter',
			{
				reign: {
					primary: '#51b4d8',
					secondary: '#2992c5',
					accent: '#F471B5',
					neutral: '#1E293B',
					'neutral-focus': '#273449',
					'base-100': '#0F172A',
					'base-content': '#FFFFFF',
					info: '#4AA8BF',
					success: '#2DD4BF',
					warning: '#F4BF50',
					error: '#EA4034',
				},
			},
		],
	},
}
