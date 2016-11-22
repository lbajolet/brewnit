import { Component, Input } from '@angular/core';
import { Yeast } from '../model/entities'

@Component({
	selector: 'yeast-card',
	template: `
<md-card>
	<md-card-title>{{yeast.name}}</md-card-title>
	<md-card-content>
		<div>
			<md-input disabled placeholder='brand' value='{{yeast.brand}}'></md-input>
			<md-input disabled placeholder='attenuation' value='{{yeast.attenuation}}'></md-input>
		</div>
		<div *ngIf='yeast.aliases.length != 0'>
			<div *ngFor='let al of yeast.aliases'>
				<md-input disabled placeholder='alias' value={{al}}></md-input>
			</div>
		</div>
	</md-card-content>
</md-card>`
})
export class YeastCard {
	@Input() yeast: Yeast
};
