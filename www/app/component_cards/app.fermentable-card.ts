import { Component, Input } from '@angular/core';
import { Fermentable } from '../model/entities'

@Component({
	selector: 'fermentable-card',
	template: `
<md-card>
	<md-card-title>{{ferm.name}}</md-card-title>
	<md-card-content>
		<div>
			<md-input disabled placeholder='potential' value='{{ferm.potential.value}} {{ferm.potential.unit}}'></md-input>
			<md-input disabled placeholder='colour' value='{{ferm.colour.value}} {{ferm.colour.unit}}'></md-input>
		</div>
	</md-card-content>
</md-card>`
})
export class FermentableCard {
	@Input() ferm: Fermentable
};
