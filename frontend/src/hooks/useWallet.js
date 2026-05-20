import { useState, useEffect } from 'react';
import { JsonRpcProvider, BrowserProvider } from 'ethers';

export function useWallet() {
  const [account, setAccount] = useState(null);
  const [provider, setProvider] = useState(null);
  const [chainId, setChainId] = useState(null);
  const [balance, setBalance] = useState(null);
  const [isConnected, setIsConnected] = useState(false);

  const connectWallet = async () => {
    try {
      if (!window.ethereum) {
        alert('Please install MetaMask');
        return;
      }

      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });

      // Use BrowserProvider (MetaMask) for transactions
      const browserProvider = new BrowserProvider(window.ethereum);
      const signer = await browserProvider.getSigner();
      const address = await signer.getAddress();
      const network = await browserProvider.getNetwork();

      // Use public RPC for reading data
      const publicProvider = new JsonRpcProvider(
        'https://sepolia-rollup.arbitrum.io/rpc'
      );

      const balanceWei = await publicProvider.getBalance(address);
      const balanceEth = (parseFloat(balanceWei) / 1e18).toFixed(4);

      setAccount(address);
      setProvider(browserProvider);
      setChainId(Number(network.chainId));
      setBalance(balanceEth);
      setIsConnected(true);

      console.log('Connected:', { address, chainId: network.chainId, balance: balanceEth });
    } catch (error) {
      console.error('Connection error:', error);
    }
  };

  const disconnectWallet = () => {
    setAccount(null);
    setProvider(null);
    setChainId(null);
    setBalance(null);
    setIsConnected(false);
  };

  useEffect(() => {
    const checkConnection = async () => {
      if (window.ethereum) {
        try {
          const accounts = await window.ethereum.request({
            method: 'eth_accounts',
          });
          if (accounts.length > 0) {
            connectWallet();
          }
        } catch (error) {
          console.log('Not connected');
        }
      }
    };

    checkConnection();

    if (window.ethereum) {
      window.ethereum.on('accountsChanged', (accounts) => {
        if (accounts.length === 0) {
          disconnectWallet();
        } else {
          connectWallet();
        }
      });

      window.ethereum.on('chainChanged', () => {
        connectWallet();
      });
    }

    return () => {
      if (window.ethereum) {
        window.ethereum.removeAllListeners?.('accountsChanged');
        window.ethereum.removeAllListeners?.('chainChanged');
      }
    };
  }, []);

  return {
    account,
    provider,
    chainId,
    balance,
    isConnected,
    connectWallet,
    disconnectWallet,
  };
}
