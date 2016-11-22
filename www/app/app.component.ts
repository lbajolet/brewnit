import { Component, OnInit } from '@angular/core';
import { HopCard } from './component_cards/app.hop'
import { FermentableCard } from './component_cards/app.fermentable-card'
import { YeastCard } from './component_cards/yeast-card'
import { HopService, FermentableService, YeastService } from './services/components'
import { Hop, Fermentable, Yeast } from './model/entities'

@Component({
	selector: 'brewnit',
	templateUrl: 'app/app.brewnit.html',
	providers: [ HopService, FermentableService, YeastService ]
})
export class AppComponent implements OnInit {

	hops: Hop[];
	fermentables: Fermentable[];
	yeasts: Yeast[];

	constructor(private hopService: HopService,
		   private fermService: FermentableService,
		   private yeastService: YeastService) { }

	ngOnInit(): void {
		this.hopService.getHops()
			.then(hops => { console.log("Setting Hops"); this.hops = hops; });
		this.fermService.getFermentables()
			.then(ferms => this.fermentables = ferms);
		this.yeastService.getYeasts()
			.then(yeasts => this.yeasts = yeasts);
	}
}
