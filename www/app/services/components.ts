import { Injectable } from '@angular/core';
import { Headers, Http } from '@angular/http';
import { Hop, Fermentable, Unit, Yeast } from '../model/entities'

import 'rxjs/add/operator/toPromise';

@Injectable()
export class BrewnitHttpService {
	serviceUrl;

	constructor(private http: Http) {}

	private handleError(error): Promise<any> {
		console.error(`Error deserializing Object due to "${error}"`);
		return Promise.reject(error.message || error);
	}

	fetchData(): Promise<any> {
		return this.http.get(this.serviceUrl)
			.toPromise()
			.catch(this.handleError);
	}
}

export class HopService extends BrewnitHttpService{
	serviceUrl = 'http://localhost:4000/api/hops'

	getHops(): Promise<Hop[]> {
		return this.fetchData().then(response => response.json() as Hop[]);
	}
}

export class FermentableService extends BrewnitHttpService{
	serviceUrl = 'http://localhost:4000/api/fermentables';

	getFermentables(): Promise<Fermentable[]> {
		return this.fetchData().then(resp => resp.json() as Fermentable[])
	}
}

export class YeastService extends BrewnitHttpService{
	serviceUrl = 'http://localhost:4000/api/yeasts';

	getYeasts(): Promise<Yeast[]> {
		return this.fetchData().then(resp => resp.json() as Yeast[])
	}
}
