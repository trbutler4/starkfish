import Head from 'next/head'
import { useBlock } from '@starknet-react/core'
import WalletBar from '../components/WalletBar'
import ChessBoard from '@/components/ChessBoard'

export default function Home() {
  const { data, isLoading, isError } = useBlock({
    refetchInterval: 3000,
    blockIdentifier: 'latest',
  })
  return (
    <>
      <Head>
        <title>Starkfish</title>
        <meta name="description" content="Starknet chess engine" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <main>
        <div>
          {isLoading
            ? 'Loading...'
            : isError
            ? 'Error while fetching the latest block hash'
            : `Latest block hash: ${data?.block_hash}`}
        </div>
        <WalletBar />
        <div style={{ padding: '80px' }}>
          <ChessBoard />
        </div>
      </main>
    </>
  )
}
