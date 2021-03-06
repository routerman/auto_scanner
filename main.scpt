JsOsaDAS1.001.00bplist00�Vscript_
�const target = {
	title: "sample_title",
	x1: 511,
	x2: 1215,
	saveTo: "/path/to/"
};

class AutoScanner {

	constructor (target) {

		// default
		this.app = "Something";
		this.startPage = 1;
		this.endPage = 1000;
		this.colorPDF = true;
		this.grayPDF = true;
		this.deleteImg = true;
		this.y1 = 24;
		this.y2 = 1021;
		this.turn = "left";
		this.saveTo = "~/";
		
		Object.assign(this, target);

		this.target_app = Application(this.app);
		this.sys = Application("System Events");
		this.script_app = Application.currentApplication();
		this.script_app.includeStandardAdditions = true;
		this.dirname = this._getMakeSaveTo(this.title);
	}

	_getMakeSaveTo (title) {
		const timestamp = Date.now();
		const dirname = this.saveTo + timestamp + "_" + title;
		this.script_app.doShellScript(`mkdir "${dirname}"`);
		return dirname;
	}
		
	_getRangeOption() {
		const w = this.x2 - this.x1;
		const h = this.y2 - this.y1;
		return `-R ${this.x1},${this.y1},${w},${h}`;
	}
	
	_getFilePath(page) {
		page = String(page).padStart(4, "0");
		return `${this.dirname}/${this.title}_${page}.png`;
	}

	_getScanCommand(page) {
		return `screencapture -xr -t png ${this._getRangeOption()} "${this._getFilePath(page)}"`;
	}

	_scanPage (page) {
		this.target_app.activate();
		delay(0.5);
		this.script_app.doShellScript(this._getScanCommand(page));
		delay(0.5);
	}

	_turnPage () {
		if (this.turn == "right"){
			this.sys.keyCode(124);
		} else if (this.turn == "left") {
			this.sys.keyCode(123);
		}
	}
	
	_getFileSize(filepath){
		return parseInt(this.script_app.doShellScript(`ls -la "${filepath}" | awk '{ printf $5 }'`));
	}
	
	_isSamePage (pageA, pageB){
		if (pageA < this.startPage) return false;
		const sizeA = this._getFileSize(this._getFilePath(pageA));
		const sizeB = this._getFileSize(this._getFilePath(pageB));
		const diff = Math.abs(sizeA - sizeB) / (sizeA + sizeB);
		const same = (diff < 0.00001);
		if (same) {
			//this.script_app.displayDialog(diff);
		}
		return same;
	}

	scanAll() {
		for (let page = this.startPage; page <= this.endPage; page++){
			this._scanPage(page);
			this._turnPage();
			if (this._isSamePage(page-1, page)) {
				this.script_app.doShellScript(`rm "${this._getFilePath(page)}"`);
				break;
			}
		}
	}
	
	convertToPDF () {
		if (this.colorPDF) {
			this.script_app.doShellScript(`cd "${this.dirname}"; /usr/local/bin/convert *.png "${this.title}.pdf"`);
		}
		if (this.grayPDF) {
			this.script_app.doShellScript(`cd "${this.dirname}"; /usr/local/bin/convert *.png -type GrayScale "${this.title}_GrayScale.pdf"`);
		}
		if (this.deleteImg) {
			this.script_app.doShellScript(`cd "${this.dirname}"; rm *.png`);
		}
		this.script_app.displayDialog("converted!");
	}
}


const scanner = new AutoScanner(target);
scanner.scanAll();
scanner.convertToPDF();
                               jscr  ��ޭ