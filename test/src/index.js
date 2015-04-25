require('./main.less');

window.m = require('mithril');


m.module(document.body, {
	view: ()=> {
		return (
			<div id="apps-list">
				{
					this.apps.map((app)=>{
						var iconStyle = {
							background: 'url("http://127.0.0.1:80' + app.path + app.manifest.icon + '")', 
						 	backgroundSize: '64px'
						};

						return (
							<div class="app">
								<div class="general">
									<div class="icon" style={iconStyle}></div>
									<div class="name">
										{app.manifest.locales.ru.name}
									</div>
									<div class="add">
										<button onclick={this.addLabel.bind(app)}>Создать ярлык</button>
									</div>
								</div>
								<div class="detail">
									<div class="item">
										<span class="name">Описание:</span> <span class="value">{app.manifest.description}</span>
									</div>
									<div class="item">
										<span class="name">Версия:</span> <span class="value">{app.manifest.version}</span>
									</div>
									<div class="item">
										<span class="name">Автор:</span> <span class="value">{app.manifest.developer.name}</span>
									</div>
									<div class="item">
										<span class="name">Время установки:</span> <span class="value">{app.install_time}</span>
									</div>
									<div class="item">
										<span class="name">Сайт:</span> <span class="value">{app.manifest.developer.url}</span>
									</div>
									<div class="item">
										<span class="name">Языки:</span> <span class="value">{Object.keys(app.manifest.locales).join(',')}</span>
									</div>
									<div class="item">
										<span class="name">Права:</span> <span class="value">{this.getPermissions(app.manifest)}</span>
									</div>
								</div>
							</div>
						);
					})
				}
			</div>
		);
	},
	controller: () => {
		this.apps = [];

		AppsAPI.get('apps.list', (apps)=>{
			this.apps = apps;
			m.redraw();
		});

		this.getPermissions = (manifest)=> {

			if(typeof manifest.permissions === 'array') {
				return manifest.permissions.join(',');
			} else {
				return manifest.permissions;
			}
		};


		this.addLabel = function() {
			var a = this;
			AppsAPI.get('labels', (list)=> {
				list.push([{
	                app: a,
	                left: 10,
	                top: 10,
	                title: a.manifest.locales.ru.name,
	                icon: a.path + a.manifest.icon,
	                selected: false
	            }])

	            AppsAPI.set('labels', list); 

			})
		};
	}
})