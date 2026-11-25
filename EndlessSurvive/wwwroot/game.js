// Tastatursteuerung: leitet Tastendruecke an die Blazor-Komponente weiter.
window.esGame = {
    ref: null,
    handler: null,
    register(dotnetRef) {
        this.ref = dotnetRef;
        if (this.handler) return;
        this.handler = (e) => {
            if (!this.ref) return;
            const t = e.target;
            if (t && (t.tagName === 'INPUT' || t.tagName === 'TEXTAREA')) return;
            if (e.ctrlKey || e.metaKey || e.altKey) return;
            if (['ArrowUp', 'ArrowDown', 'ArrowLeft', 'ArrowRight', ' '].includes(e.key)) e.preventDefault();
            if (e.repeat && !e.key.startsWith('Arrow') && !'wasd'.includes(e.key.toLowerCase())) return;
            this.ref.invokeMethodAsync('OnKey', e.key).catch(() => { });
        };
        window.addEventListener('keydown', this.handler);
        let t = null;
        window.addEventListener('resize', () => {
            clearTimeout(t);
            t = setTimeout(() => { if (this.ref) this.ref.invokeMethodAsync('OnResize', window.innerWidth).catch(() => { }); }, 200);
        });
    },
    width() { return window.innerWidth; },
    unregister() {
        this.ref = null;
    },
    scrollTop(el) { if (el) el.scrollTop = el.scrollHeight; }
};
