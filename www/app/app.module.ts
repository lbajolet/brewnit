import { NgModule }      from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { MaterialModule } from '@angular/material';
import { HttpModule }    from '@angular/http';
import { AppComponent }  from './app.component';
import { HopCard } from './component_cards/app.hop';
import { FermentableCard } from './component_cards/app.fermentable-card'
import { YeastCard } from './component_cards/yeast-card'

@NgModule({
	imports:      [
		BrowserModule,
		MaterialModule.forRoot(),
		HttpModule
	],
	declarations: [
		AppComponent,
		HopCard,
		FermentableCard,
		YeastCard
	],
	bootstrap:    [
		AppComponent
	]
})
export class AppModule { }
