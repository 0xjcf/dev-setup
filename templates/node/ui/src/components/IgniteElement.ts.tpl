import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';

@customElement('ignite-element')
export class IgniteElement extends LitElement {
  static styles = css`
    :host {
      display: block;
    }
    
    .ignite-element {
      padding: 1rem;
    }
  `;

  @property({ type: String })
  name = 'World';

  render() {
    return html`
      <div class="ignite-element">
        <h1>Hello, ${this.name}!</h1>
        <slot></slot>
      </div>
    `;
  }
}

declare global {
  interface HTMLElementTagNameMap {
    'ignite-element': IgniteElement;
  }
} 