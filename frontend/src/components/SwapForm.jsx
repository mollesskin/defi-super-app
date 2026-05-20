import { useState } from 'react';
import { parseEther } from 'ethers';
import { useWalletContext } from '../context/WalletContext';
import { getAddresses } from '../config/addresses';
import AMMFactoryABI from '../abi/AMMFactory.json';

export default function SwapForm() {
  const [tokenIn, setTokenIn] = useState('');
  const [tokenOut, setTokenOut] = useState('');
  const [amountIn, setAmountIn] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [txHash, setTxHash] = useState('');
  
  const { isConnected, chainId, provider } = useWalletContext();

  const handleSwap = async (e) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setTxHash('');

    if (!isConnected) {
      setError('Please connect wallet');
      return;
    }

    if (!amountIn || !tokenIn || !tokenOut) {
      setError('Please fill all fields');
      return;
    }

    if (parseFloat(amountIn) <= 0) {
      setError('Amount must be greater than 0');
      return;
    }

    try {
      setLoading(true);
      
      const addresses = getAddresses(chainId);
      const signer = await provider.getSigner();
      
      const { Contract } = await import('ethers');
      const ammContract = new Contract(
        addresses.ammFactory,
        AMMFactoryABI.abi,
        signer
      );

      const amountInWei = parseEther(amountIn);
      
      console.log('Swapping:', {
        tokenIn,
        tokenOut,
        amountIn: amountInWei.toString(),
      });

      const tx = await ammContract.swap(
        tokenIn,
        tokenOut,
        amountInWei,
        0
      );

      setTxHash(tx.hash);
      await tx.wait();
      
      setSuccess(`Swap successful! Tx: ${tx.hash.substring(0, 10)}...`);
      setTokenIn('');
      setTokenOut('');
      setAmountIn('');
    } catch (err) {
      console.error('Swap error:', err);
      setError(err.reason || err.message || 'Swap failed');
    } finally {
      setLoading(false);
    }
  };

  return (
    <form onSubmit={handleSwap} className="space-y-4">
      <div>
        <label className="block text-sm font-semibold mb-2">Token In Address</label>
        <input
          type="text"
          value={tokenIn}
          onChange={(e) => setTokenIn(e.target.value)}
          placeholder="0x23c6a6da50904C036C9A7d1f54e5F789ADc68aD6"
          className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white placeholder-gray-500 focus:border-blue-500 focus:outline-none transition"
        />
      </div>

      <div>
        <label className="block text-sm font-semibold mb-2">Amount</label>
        <input
          type="number"
          step="0.0001"
          value={amountIn}
          onChange={(e) => setAmountIn(e.target.value)}
          placeholder="1.0"
          className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white placeholder-gray-500 focus:border-blue-500 focus:outline-none transition"
        />
      </div>

      <div>
        <label className="block text-sm font-semibold mb-2">Token Out Address</label>
        <input
          type="text"
          value={tokenOut}
          onChange={(e) => setTokenOut(e.target.value)}
          placeholder="0x39D48b50Ca34F379c49C0214A4F1DC58D829f0aC"
          className="w-full bg-gray-700 border border-gray-600 rounded px-4 py-2 text-white placeholder-gray-500 focus:border-blue-500 focus:outline-none transition"
        />
      </div>

      {error && (
        <div className="bg-red-600 text-white p-3 rounded border border-red-700">
          <p className="font-semibold">Error</p>
          <p className="text-sm">{error}</p>
        </div>
      )}

      {success && (
        <div className="bg-green-600 text-white p-3 rounded border border-green-700">
          <p className="font-semibold">Success!</p>
          <p className="text-sm">{success}</p>
          {txHash && (
            <a 
              href={`https://sepolia.arbiscan.io/tx/${txHash}`}
              target="_blank"
              rel="noopener noreferrer"
              className="text-blue-200 hover:underline text-sm mt-2 block"
            >
              View on Arbiscan
            </a>
          )}
        </div>
      )}

      <button
        type="submit"
        disabled={loading || !isConnected}
        className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-600 p-3 rounded font-bold transition"
      >
        {loading ? 'Swapping...' : 'Execute Swap'}
      </button>
    </form>
  );
}
