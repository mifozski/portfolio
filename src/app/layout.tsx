import React from 'react';
import type { Metadata } from 'next';
import { Inter } from 'next/font/google';

import { Navbar } from '@/components/Navbar';
import './globals.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'Andrey | Full-stack Developer<',
  description: 'A porfolio for the personal pet projects',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <Navbar />
        {children}
      </body>
    </html>
  );
}
