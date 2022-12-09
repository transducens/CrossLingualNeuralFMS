import xml.etree.ElementTree as ET
from vocab import Vocab
from mosestokenizer import *
from xml.sax.saxutils import escape


class TMXFile:

    def __init__(self, sl, tl):
        self.slsegs = []
        self.tlsegs = []
        self.slorigsegs = []
        self.tlorigsegs = []
        self.slang = sl.lower()
        self.tlang = tl.lower()
        self.stokenizer = MosesTokenizer(lang=self.slang, escape_xml=False)
        self.ttokenizer = MosesTokenizer(lang=self.tlang, escape_xml=False)

    def read_file(self, filepath):
        tree = ET.parse(filepath)
        root = tree.getroot()
        for tu in root[1].findall("tu"):
            source=[]
            target=[]
            for tuv in tu.findall("tuv"):
                if tuv.attrib["lang"].lower().split("-")[0] == self.slang:
                    for seg in tuv.findall("seg"):
                        if seg.text != None and len(seg.text.strip())>0:
                            source.append(seg.text)
                elif tuv.attrib["lang"].lower().split("-")[0] == self.tlang:
                    for seg in tuv.findall("seg"):
                        if seg.text != None and len(seg.text.strip())>0:
                            target.append(seg.text)

            if len(source) > 0 and len(target) > 0:
                self.slorigsegs.append(" ".join(source))
                self.tlorigsegs.append(" ".join(target))
                self.slsegs.append(self.idx_segment(" ".join(source), self.stokenizer))
                self.tlsegs.append(self.idx_segment(" ".join(target), self.ttokenizer))

    def idx_segment(self, seg, tokenizer):
        idx_seg = []
        tok_seg = tokenizer.tokenize(seg)
        for tok in tok_seg:
            if len(tok) > 0:
                id = Vocab.add_word_to_vocab(tok.lower())
                idx_seg.append(id)
        return idx_seg

    def decode_idx_segment(self, seg):
        output = []
        for id in seg:
            output.append(Vocab.get_word_from_id(id))
        return " ".join(output)

    def write(self, ofile, turange=None):
        if turange == None:
            turange = (0, len(self.slorigsegs)-1)
        ofile.write("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        ofile.write("<!DOCTYPE tmx SYSTEM \"tmx14.dtd\">\n")
        ofile.write("<tmx version=\"1.4\">\n")
        ofile.write("  <header creationtool=\"tmx_tools\" segtype=\"sentence\" datatype=\"PlainText\" adminlang=\"EN\" srclang=\"EN\"></header>\n")
        ofile.write("  <body>\n")
        linecount = 0
        for s,t in zip(self.slorigsegs,self.tlorigsegs):
            if linecount >= turange[0]:
                ofile.write("    <tu>\n")
                ofile.write("      <tuv lang=\""+self.slang+"\">\n")
                ofile.write("        <seg>"+escape(s)+"</seg>\n")
                ofile.write("      </tuv>\n")
                ofile.write("      <tuv lang=\""+self.tlang+"\">\n")
                ofile.write("        <seg>"+escape(t)+"</seg>\n")
                ofile.write("      </tuv>\n")
                ofile.write("    </tu>\n")
            linecount += 1
            if linecount >= turange[1]:
                break
        ofile.write("  </body>\n")
        ofile.write("</tmx>")
