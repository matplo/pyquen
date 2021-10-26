#!/usr/bin/env python3

import argparse
import sys
import os
import re
import random 
import tqdm

import importlib
root_avail = importlib.util.find_spec("ROOT")
if root_avail is not None:
	import ROOT

def parse_pyquen():

	parser = argparse.ArgumentParser()
	parser.add_argument('-i', '--input', help='input file', default='', type=str)
	parser.add_argument('-s', '--stream', help='input from stdin', action='store_true')
	parser.add_argument('-o', '--output', help='input from stdin', default='', type=str)
	parser.add_argument('-n', '--nevents', help='nevents', default=0, type=int)
	parser.add_argument('-c', '--nperfile', help='nevents per output file', default=1000, type=int)
	parser.add_argument('-e', '--show-errors', help='show errors if found', default=False, action='store_true')
	args = parser.parse_args()

	# time based
	random.seed(None)
	run_number = random.randint(0, 1000000)
	event_number = 0
	outlines = []

	read_parts = False

	input_data = None
	if args.input:
		input_data = open(args.input).readlines()

	if args.stream:
		input_data = sys.stdin

	if input_data is None:
		parser.print_help()
		return

	#root output
	outr = None
	tn = None

	# initialize/set outputs
	nfile = 0
	pbar = None
	if args.output:
		foutname = os.path.splitext(args.output)[0] + '_{}.csv'.format(nfile)
		outf = open(foutname, 'w')
		if args.nevents > 0:
			pbar = tqdm.tqdm(total=args.nevents)
		else:
			pbar = tqdm.tqdm()			
		if root_avail:
			foutname_root = os.path.splitext(foutname)[0] + '.root'
			outr = ROOT.TFile(foutname_root, 'recreate')
			tn = ROOT.TNtuple('tree_Particle_gen', 'particles from pyquen', 'run_number:ev_id:ParticlePt:ParticleEta:ParticlePhi:ParticlePID')
	else:
		outf = sys.stdout


	header = False
	for sline in input_data:
		l = sline.lstrip().rstrip('\n')
		if '#[pyquen] START Event #' in l:
			event_number = int(l.split('Event #')[1].split('Imp')[0])
			if event_number % args.nperfile == 0:
				if args.output:
					header = False
					nfile = nfile + 1
					foutname = os.path.splitext(args.output)[0] + '_{}.csv'.format(nfile)
					if outf != sys.stdout:
						outf.close()
						outf = open(foutname, 'w')
					if root_avail:
						if tn and outr:
							outr.cd()
							tn.Write()
							outr.Write()
							outr.Purge()
							outr.Close()
						foutname_root = os.path.splitext(foutname)[0] + '.root'
						outr = ROOT.TFile(foutname_root, 'recreate')
						tn = ROOT.TNtuple('tree_Particle_gen', 'particles from pyquen', 'run_number:ev_id:ParticlePt:ParticleEta:ParticlePhi:ParticlePID')
			if pbar:
				pbar.update(1)
			read_parts = True
			continue
		if '#[pyquen] END Event #' in l:
			read_parts = False
			continue
		if '#[pyquen] END OF RUN' in l:
			print('[i] end of run reached')
			break
		if read_parts:
			l = re.sub(' +', ' ', '{}'.format(l))
			#print(l)
			cols = l.split(' ')
			if len(cols) < 1:
				continue
			if len(cols) < 10:
				if not cols[0].isdigit():
					continue
				if args.show_errors:
					print('[e] bad particle line', l, file=sys.stderr)
				new_cols = []
				for c in cols:
					_c = c
					if len(c.split('-')) > 1:
						_c = c.replace('-', ' -')
					new_cols.append(_c)
				l = ' '.join(new_cols)
				if args.show_errors:
					print('           fixed line', l, file=sys.stderr)
				l = re.sub(' +', ' ', '{}'.format(l))
				cols = l.split(' ')
				if len(cols) < 10:
					print('[fatal-e] unable to recover line', l, file=sys.stderr)
					return
			if cols[0].isdigit():
				vals = l.split()
				pid = int(vals[3])
				px = float(vals[5])
				py = float(vals[6])
				pz = float(vals[7])
				E  = float(vals[8])
				m  = float(vals[9])
				lv = ROOT.Math.PxPyPzMVector(px, py, pz, m)
				# print(lv.E() - E)
				outl = '{},{},{},{},{},{}'.format(run_number, event_number, l.replace(' ', ','), lv.Pt(), lv.Eta(), lv.Phi())
				#outlines.append(outl)
				print(outl, file=outf)
				if tn:
					# tn = ROOT.TNtuple('tree_Particle_gen', 'particles from pyquen', 'run_number:ev_id:ParticlePt:ParticleEta:ParticlePhi:ParticlePID')
					tn.Fill(run_number, event_number, lv.Pt(), lv.Eta(), lv.Phi(), pid)
			if header is False:
				if 'I particle/jet KS KF orig p_x p_y p_z E m' in l:
					outl = '{},{},{},pt,eta,phi'.format(run_number, event_number, l.replace(' ', ',').replace('particle/jet', 'p'))
					#outlines.append(outl)
					print(outl, file=outf)
					header = True
			if args.nevents > 0:
				if pbar.n >= args.nevents:
					break
			continue
	pbar.close()

	if tn:
		outr.cd()
		tn.Write()
		outr.Write()
		outr.Purge()
		outr.Close()

	if outf != sys.stdout:
		outf.close()

if __name__ == '__main__':
	parse_pyquen()

