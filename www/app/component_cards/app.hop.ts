import { Component, Input } from '@angular/core';
import { Hop } from '../model/entities'

@Component({
	selector: 'hop-card',
	template: `
<md-card>
	<md-card-title>{{hop.name}}</md-card-title>
</md-card>`
})
export class HopCard {
	@Input() hop: Hop
};
