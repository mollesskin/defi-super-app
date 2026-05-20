import { createClient, configureChains } from 'wagmi';
import { arbitrumSepolia, optimismSepolia, baseSepolia } from 'wagmi/chains';
import { publicProvider } from 'wagmi/providers/public';
import { InjectedConnector } from 'wagmi/connectors/injected';

const { chains, provider, webSocketProvider } = configureChains(
  [arbitrumSepolia, optimismSepolia, baseSepolia],
  [publicProvider()],
);

export const client = createClient({
  autoConnect: true,
  connectors: [
    new InjectedConnector({ chains }),
  ],
  provider,
  webSocketProvider,
});

export { chains };
